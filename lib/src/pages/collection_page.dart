import 'package:flutter/material.dart';

import '../component.dart';
import '../service.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Discovery'),
            Tab(text: 'Favorites'),
          ],
        ),
        body: TabBarView(
          children: [
            DiscoveryTab(),
            FavoriteTab(),
          ],
        ),
      ),
    );
  }
}

class DiscoveryTab extends StatefulWidget {
  const DiscoveryTab({super.key});

  @override
  State<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends State<DiscoveryTab> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: RemoteApi.getSights(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
          );
        } else {
          final sights = snapshot.data;
          return (sights ?? []).isNotEmpty
              ? ListView.builder(
                  itemCount: sights!.length,
                  itemBuilder: (context, index) {
                    final id =
                        CollectionApi.getDiscovery(sights[index].sightID);
                    return id != null
                        ? FutureBuilder(
                            future: RemoteApi.getRecord(id),
                            builder: (context, snapshot) {
                              final record = snapshot.data;
                              final imageID = record?.imageID;
                              final name = record?.sightName;
                              final description = record?.copywriting;
                              return CollectionItem(
                                id: id,
                                imageID: imageID,
                                name: name,
                                description: description,
                              );
                            })
                        : CollectionItem(
                            id: id,
                            imageID: null,
                            name: sights[index].sightName,
                            description: sights[index].sightDescription,
                          );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 100,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'No discoveries yet',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
        }
      },
    );
  }
}

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: (CollectionApi.favoriteIDs ?? []).isNotEmpty
          ? ListView.builder(
              itemCount: (CollectionApi.favoriteIDs ?? []).length,
              itemBuilder: (context, index) {
                final id = (CollectionApi.favoriteIDs ?? [])[index];
                return FutureBuilder(
                  future: RemoteApi.getRecord(id),
                  builder: (context, snapshot) {
                    final record = snapshot.data;
                    final imageID = record?.imageID;
                    final name = record?.sightName;
                    final description = record?.copywriting;
                    return CollectionItem(
                      id: id,
                      imageID: imageID,
                      name: name,
                      description: description,
                      onFavorite: () => setState(() {}),
                    );
                  },
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 100,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
