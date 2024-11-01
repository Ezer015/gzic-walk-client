import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/page.dart';
import 'src/service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  await RemoteApi.init();
  await CollectionApi.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GZIC Walk',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Use system theme mode (light/dark)
      routes: {
        '/': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/result/')) {
          final uri = Uri.parse(settings.name!);
          final imageID =
              uri.pathSegments.length == 2 ? uri.pathSegments[1] : null;

          if (imageID == null) {
            return MaterialPageRoute(
              builder: (context) => Center(
                child: Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                  size: 50,
                ),
              ),
            );
          }

          final parsedID = int.tryParse(imageID);
          if (parsedID == null) {
            return MaterialPageRoute(
              builder: (context) => Center(
                child: Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                  size: 50,
                ),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (context) => ResultPage(imageID: parsedID),
          );
        }

        return null;
      },
      builder: (context, child) {
        return SafeArea(child: child!);
      },
    );
  }
}
