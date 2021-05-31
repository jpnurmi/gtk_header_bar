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
          label: 'button',
          onClicked: () => print('click'),
        ),
        GtkToggleButton(
          label: 'toggle',
          sensitive: false,
          onToggled: (value) => print('toggle: $value'),
        ),
      ],
      end: <GtkWidget>[
        GtkCheckButton(
          label: 'check',
          active: true,
          visible: false,
          onToggled: (value) => print('check: $value'),
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
