import 'package:flutter/material.dart';
import 'package:gtk_header_bar/gtk_header_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var counter = 0;

  @override
  Widget build(BuildContext context) {
    setGtkHeaderBar(
      GtkHeaderBar(
        title: 'title...',
        subtitle: 'subtitle...',
        start: <GtkWidget>[
          GtkButton(
            label: 'button $counter',
            key: const ValueKey('button1'),
            onClicked: () => print('click $counter'),
          ),
          GtkButton(
            label: 'button 2',
            key: const ValueKey('button2'),
            onClicked: () => print('click 2'),
          ),
          GtkToggleButton(
            label: 'toggle',
            key: const ValueKey('button3'),
            sensitive: counter % 2 == 0,
            onToggled: (value) => print('toggle: $value'),
          ),
        ],
        end: <GtkWidget>[
          GtkCheckButton(
            label: 'check',
            key: const ValueKey('button4'),
            active: true,
            visible: counter % 2 == 1,
            onToggled: (value) => print('check: $value'),
          ),
          GtkEntry(
            text: 'entry',
            //key: const ValueKey('entry'),
            onActivate: (value) => print('entry: $value'),
          ),
        ],
      ),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GtkHeaderBar example'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('Rebuild'),
            onPressed: () => setState(() => ++counter),
          ),
        ),
      ),
    );
  }
}
