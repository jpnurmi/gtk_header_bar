import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtk_header_bar/gtk_header_bar.dart';

void main() {
  const MethodChannel channel = MethodChannel('gtk_header_bar');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await GtkHeaderBar.platformVersion, '42');
  });
}
