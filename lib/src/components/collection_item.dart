import 'package:flutter/material.dart';

import 'package:screenshot/screenshot.dart';

import '../service.dart';
import 'sharing_card.dart';

class CollectionItem extends StatelessWidget {
  final int? id;
  final int? imageID;
  final String? name;
  final String? description;
  final VoidCallback? onFavorite;

  const CollectionItem({
    super.key,
    required this.id,
    required this.imageID,
    required this.name,
    required this.description,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: imageID != null
                  ? Image.network(
                      RemoteApi.assembleUri(
                        RemoteApiPath.image,
                        pathParameter: imageID.toString(),
                      ).toString(),
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.error,
                            color: Theme.of(context).colorScheme.error,
                            size: 50,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 110,
                      height: 110,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.1),
                    ),
            ),
            const SizedBox(width: 16.0),
            // Name and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  name != null
                      ? Text(
                          name!,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                  const SizedBox(height: 8.0),
                  description != null
                      ? Text(
                          description!,
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < 4; i++) ...[
                              Container(
                                width: double.infinity,
                                height: 14.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              const SizedBox(height: 7.0),
                            ]
                          ]..removeLast(),
                        ),
                ],
              ),
            ),
            // Share button
            if (imageID != null)
              Center(
                child: IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        ScreenshotController screenshotController =
                            ScreenshotController();
                        return Center(
                          child: SharingCard(
                            screenshotController: screenshotController,
                            id: id,
                            imageID: imageID,
                            name: name,
                            description: description,
                            onFavorite: onFavorite,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
