import 'package:flutter/material.dart';

// When published, use: import 'package:cover_generator/cover_generator.dart';
import '../lib/cover_generator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Cover Generator Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap any widget with CoverCaptureWrapper to add a capture button.
    return CoverCaptureWrapper(
      showButton: true,
      backgroundColor: Colors.white,
      child: Scaffold(
        appBar: AppBar(title: const Text('My App')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _Card('First Achievement', 'Learned Flutter', '🎉'),
            _Card('Second Achievement', 'Published App', '🚀'),
            _Card('Third Achievement', '1000 Downloads', '⭐'),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;

  const _Card(this.title, this.subtitle, this.emoji);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 32)),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
