import 'package:flutter/material.dart';

import '../service.dart';

class ResultPage extends StatefulWidget {
  final int imageID;

  const ResultPage({
    super.key,
    required this.imageID,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final TextEditingController _nameController =
      TextEditingController(text: "");
  late final TextEditingController _descriptionController =
      TextEditingController(text: "");
  int? id;
  String name = "";
  String description = "";

  bool _nameEditable = false;
  bool _recognitionCompleted = false;
  bool _imageAvailable = false;

  @override
  void initState() {
    super.initState();
    RemoteApi.getRecognitionResult(widget.imageID).then((sight) {
      if (sight == null) {
        setState(() {
          _recognitionCompleted = true;
          _nameEditable = true;
        });
        return;
      }
      setState(() {
        _nameController.text = sight.sightName;
        _descriptionController.text = sight.sightDescription;
        id = sight.sightID;
        name = sight.sightName;
        description = sight.sightDescription;
        _recognitionCompleted = true;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 8,
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: Image.network(
                            RemoteApi.assembleUri(
                              RemoteApiPath.image,
                              pathParameter: widget.imageID.toString(),
                            ).toString(),
                            width: MediaQuery.of(context).size.width * 0.8,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => setState(() => _imageAvailable = true));
                            return child;
                          }
                          return Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.width * 0.6,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              ),
                            ],
                          );
                        }, errorBuilder: (context, error, stackTrace) {
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() => _imageAvailable = false));
                          return Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              Center(
                                child: Icon(
                                  Icons.error,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 50,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    // Name with Switch
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "What",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Stack(
                                    children: [
                                      TextField(
                                        readOnly: !_nameEditable,
                                        controller: _nameController,
                                        maxLines: 1,
                                        onChanged: (value) =>
                                            setState(() => name = value),
                                        decoration: InputDecoration(
                                          hintText: _recognitionCompleted
                                              ? ''
                                              : '  Processing ...',
                                          hintStyle: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.normal,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.4),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(8.0),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.2),
                                              width: 2.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_recognitionCompleted &&
                                          !_nameEditable) ...[
                                        Positioned.directional(
                                          textDirection:
                                              Directionality.of(context),
                                          end: 0,
                                          child: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => setState(
                                                () => _nameEditable = true),
                                          ),
                                        )
                                      ]
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "How",
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 12.0),
                            child: TextField(
                              readOnly: !_recognitionCompleted,
                              controller: _descriptionController,
                              maxLines: 8,
                              onChanged: (value) =>
                                  setState(() => description = value),
                              decoration: InputDecoration(
                                hintText: _recognitionCompleted
                                    ? ''
                                    : '  Processing ...',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4),
                                ),
                                contentPadding: const EdgeInsets.all(8.0),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.2),
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
              // Buttons outside the Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            if (!_recognitionCompleted || !_imageAvailable) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Processing not finished yet'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            if (name == "") {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Name cannot be empty'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            if (description == "") {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Description cannot be empty'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            final recordID = await RemoteApi.createRecord(
                              imageID: widget.imageID,
                              sightID: id,
                              sightName: name,
                              copywriting: description,
                            );
                            if (recordID == null) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to create card'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            CollectionApi.addFavorite(recordID);
                            if (id != null) {
                              CollectionApi.addDiscovery(
                                sightID: id!,
                                recordID: recordID,
                              );
                            }

                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Card created successfully'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            navigator.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.surface,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
