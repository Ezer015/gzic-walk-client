import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:cronet_http/cronet_http.dart';
import 'package:path_provider/path_provider.dart';

enum RemoteApiPath {
  image,
  sight,
  copywriting,
  record,
}

class RemoteApi {
  static final RemoteApi _instance = RemoteApi._();

  factory RemoteApi() => _instance;

  RemoteApi._();

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _instance._client = CronetClient.fromCronetEngine(
      CronetEngine.build(
        cacheMode: CacheMode.disk,
        cacheMaxSize: 512 << 20,
        storagePath: directory.path,
      ),
      closeEngine: true,
    );
  }

  static const base = '<IP>:<PORT>';
  late final http.Client _client;

  static String transformPath(RemoteApiPath path) => switch (path) {
        RemoteApiPath.image => 'image',
        RemoteApiPath.sight => 'sight',
        RemoteApiPath.copywriting => 'copywriting',
        RemoteApiPath.record => 'record',
      };

  static Uri assembleUri(
    RemoteApiPath path, {
    String? pathParameter,
    Map<String, String>? queryParameters,
  }) =>
      Uri.http(
        base,
        pathParameter != null
            ? [transformPath(path), pathParameter].join('/')
            : transformPath(path),
        queryParameters,
      );

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    try {
      return await _instance._client.get(
        url,
        headers: headers,
      );
    } catch (e) {
      return http.Response('', 500);
    }
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async =>
      _instance._client.post(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  static Future<http.Response> multipartRequest(
    Uri url, {
    required List<http.MultipartFile> files,
    Map<String, String>? headers,
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers ?? {})
      ..fields.addAll(fields ?? {})
      ..files.addAll(files);

    final streamedResponse = await _instance._client.send(request);
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<int?> uploadImage({
    required File imageFile,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: imageFile.path.split('/').last,
    );

    final response = await multipartRequest(
      assembleUri(RemoteApiPath.image),
      files: [multipartFile],
    );

    if (response.statusCode == 202) {
      try {
        final responseData = jsonDecode(response.body);
        return responseData['image_id'] as int?;
      } catch (e) {
        return null;
      }
    } else if (response.statusCode == 413) {
      // Image size too large
      return null;
    } else {
      return null;
    }
  }

  static Future<
      List<
          ({
            int sightID,
            String sightName,
            String sightDescription,
          })>?> getSights() async {
    final response = await get(assembleUri(RemoteApiPath.sight));
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        return (data as List<dynamic>)
            .map(
              (sight) => (
                sightID: sight['sight_id'] as int,
                sightName: sight['sight_name'] as String,
                sightDescription: sight['sight_description'] as String,
              ),
            )
            .toList();
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<
      ({
        int sightID,
        String sightName,
        String sightDescription,
      })?> getSight(int sightID) async {
    final response = await get(assembleUri(
      RemoteApiPath.sight,
      pathParameter: sightID.toString(),
    ));
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        return (
          sightID: data['sight_id'] as int,
          sightName: data['sight_name'] as String,
          sightDescription: data['sight_description'] as String
        );
      } catch (e) {
        return null;
      }
    } else if (response.statusCode == 404) {
      // Sight ID does not exist
      return null;
    } else {
      return null;
    }
  }

  static Future<int?> generateCopywriting({
    required String name,
    required String description,
    required String prompt,
  }) async {
    final response = await post(
      assembleUri(RemoteApiPath.copywriting),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          'name': name,
          'description': description,
          'prompt': prompt,
        },
      ),
    );
    if (response.statusCode == 202) {
      try {
        final responseData = jsonDecode(response.body);
        return responseData['copywriting_id'] as int?;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<String?> getCopywriting(int copywritingID) async {
    final response = await get(assembleUri(
      RemoteApiPath.copywriting,
      pathParameter: copywritingID.toString(),
    ));
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        return data['copywriting'] as String?;
      } catch (e) {
        return null;
      }
    } else if (response.statusCode == 202) {
      // Job is still in progress
      return null;
    } else if (response.statusCode == 404) {
      // Job ID does not exist
      return null;
    } else {
      return null;
    }
  }

  static Future<int?> createRecord({
    required int imageID,
    int? sightID,
    String? sightName,
    required String copywriting,
  }) async {
    if (sightID == null && (sightName == null || sightName.isEmpty)) {
      return null;
    }

    final response = await post(
      assembleUri(RemoteApiPath.record),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: sightID != null
          ? {
              'image_id': imageID.toString(),
              'sight_id': sightID.toString(),
              'copywriting': copywriting,
            }
          : {
              'image_id': imageID.toString(),
              'sight_name': sightName,
              'copywriting': copywriting,
            },
    );
    if (response.statusCode == 201) {
      try {
        final responseData = jsonDecode(response.body);
        return responseData['record_id'] as int?;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<
      ({
        int imageID,
        int sightID,
        String sightName,
        String copywriting,
      })?> getRecord(int recordID) async {
    final response = await get(assembleUri(
      RemoteApiPath.record,
      pathParameter: recordID.toString(),
    ));
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        return (
          imageID: data['image_id'] as int,
          sightID: data['sight_id'] as int,
          sightName: data['sight_name'] as String,
          copywriting: data['copywriting'] as String
        );
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<
      ({
        int recordID,
        int imageID,
        int sightID,
        String sightName,
        String copywriting,
      })?> getRandomRecord() async {
    final response = await get(assembleUri(RemoteApiPath.record));
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        return (
          recordID: data['record_id'] as int,
          imageID: data['image_id'] as int,
          sightID: data['sight_id'] as int,
          sightName: data['sight_name'] as String,
          copywriting: data['copywriting'] as String
        );
      } catch (e) {
        return null;
      }
    } else if (response.statusCode == 404) {
      // No records available
      return null;
    } else {
      return null;
    }
  }

  static Future<
      ({
        int? sightID,
        String sightName,
        String sightDescription,
      })?> getRecognitionResult(int imageID) async {
    return null;
  }
}
