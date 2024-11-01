import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../service.dart';

class SharingCard extends StatefulWidget {
  const SharingCard({
    super.key,
    this.screenshotController,
    required this.id,
    required this.imageID,
    required this.name,
    required this.description,
    this.onFavorite,
  });

  final ScreenshotController? screenshotController;
  final int? id;
  final int? imageID;
  final String? name;
  final String? description;
  final VoidCallback? onFavorite;

  @override
  State<SharingCard> createState() => _SharingCardState();
}

class _SharingCardState extends State<SharingCard> {
  late bool _isFavorite = CollectionApi.isFavorite(widget.id ?? -1);

  Widget enableScreenshot({
    ScreenshotController? controller,
    required Widget child,
  }) =>
      controller != null
          ? Screenshot(
              controller: controller,
              child: child,
            )
          : child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            enableScreenshot(
              controller: widget.screenshotController,
              child: Card(
                elevation: 10,
                margin: EdgeInsets.zero,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: widget.imageID != null
                                  ? Image.network(
                                      RemoteApi.assembleUri(
                                        RemoteApiPath.image,
                                        pathParameter:
                                            widget.imageID.toString(),
                                      ).toString(),
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 50,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.6,
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      // Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: widget.name != null
                            ? Text(
                                widget.name!,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12.0),
                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: widget.description != null
                            ? Text(
                                widget.description!,
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                              )
                            : Column(
                                children: [
                                  for (int i = 0; i < 6; i++) ...[
                                    Container(
                                      width: double.infinity,
                                      height: 16.0,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                  ]
                                ]..removeLast(),
                              ),
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4.0,
              right: 8.0,
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  if (widget.id != null) {
                    if (_isFavorite) {
                      CollectionApi.removeFavorite(widget.id!);
                    } else {
                      CollectionApi.addFavorite(widget.id!);
                    }
                    setState(() =>
                        _isFavorite = CollectionApi.isFavorite(widget.id!));

                    if (widget.onFavorite != null) {
                      widget.onFavorite!();
                    }
                  }
                },
              ),
            ),
          ],
        ),
        // Save button
        if (widget.screenshotController != null) ...[
          const SizedBox(height: 24.0),
          SizedBox(
            width: 65,
            height: 65,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(0),
                elevation: 8,
              ),
              onPressed: () async {
                // Capture screenshot and save to phone gallery
                final Uint8List? image =
                    await widget.screenshotController!.capture();
                if (image != null) {
                  if (context.mounted) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final result = await ImageGallerySaver.saveImage(image);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(result['isSuccess']
                            ? 'Card saved successfully'
                            : 'Save failed'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    // Close the dialog
                    navigator.pop();
                  }
                }
              },
              child: const Center(
                child: Icon(
                  Icons.save,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
