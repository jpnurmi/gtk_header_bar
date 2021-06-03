import 'package:flutter/material.dart';
import 'package:gtk_header_bar/gtk_header_bar.dart';

void main() {
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
    return GtkHeaderBar(
      title: 'title...',
      subtitle: 'subtitle...',
      start: <GtkWidget>[
        GtkButton(
          label: 'button $counter',
          onClicked: () => print('click $counter'),
        ),
        GtkMenuButton(
          label: 'menu',
          popup: GtkMenu(
            children: <GtkMenuItem>[
              for (var i = 0; i < 3; ++i)
                GtkMenuItem(
                  label: 'item $i',
                  onActivate: () => print('activate: $i'),
                ),
              GtkMenuItem(
                label: 'submenu',
                submenu: GtkMenu(
                  children: <GtkMenuItem>[
                    for (var i = 0; i < 3; ++i)
                      GtkMenuItem(
                        label: 'subitem $i',
                        onActivate: () => print('sub-activate: $i'),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
        GtkToggleButton(
          label: 'toggle',
          sensitive: counter % 2 == 0,
          onToggled: (value) => print('toggle: $value'),
        ),
      ],
      end: <GtkWidget>[
        GtkCheckButton(
          label: 'check',
          active: true,
          visible: counter % 2 == 1,
          onToggled: (value) => print('check: $value'),
        ),
        GtkEntry(
          text: 'entry',
          onActivate: (value) => print('entry: $value'),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
