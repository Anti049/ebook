import 'package:ebook_example_flutter/read.dart';
import 'package:ebook_example_flutter/write.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      routes: {
        '/': (context) => const HomePage(),
        '/read': (context) => const ReadPage(),
        '/write': (context) => const WritePage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Hello World'),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => {
                    Navigator.of(context).pushNamed('/read'),
                  },
                  child: const Text('Read'),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () => {
                    Navigator.of(context).pushNamed('/write'),
                  },
                  child: const Text('Write'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
