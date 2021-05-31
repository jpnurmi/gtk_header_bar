import 'package:flutter/material.dart';
import 'package:gtk_header_bar/gtk_header_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setGtkHeaderBar(
    GtkHeaderBar(
      title: 'title...',
      subtitle: 'subtitle...',
      start: <GtkWidget>[
        GtkButton(
          label: 'start 1',
          onClicked: () => print('start 1'),
        ),
        GtkButton(
          label: 'start 2',
          onClicked: () => print('start 2'),
        ),
      ],
      end: <GtkWidget>[
        GtkButton(
          label: 'end 1',
          onClicked: () => print('end 1'),
        ),
        GtkButton(
          label: 'end 2',
          onClicked: () => print('end 2'),
        ),
      ],
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GtkHeaderBar example'),
        ),
      ),
    );
  }
}
