import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/services/api_service.dart';
import 'package:path_provider/path_provider.dart';

@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Test', () {
    late MockClient mockClient;
    late File dummyFile;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Mock path_provider MethodChannel
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return '.';
      });

      mockClient = MockClient();
      dummyFile = File('dummy.jpg');
      await dummyFile.writeAsBytes([0, 1, 2, 3]);
    });

    tearDown(() async {
      if (await dummyFile.exists()) {
        await dummyFile.delete();
      }
    });

    test('enhanceImage returns a file on successful API call', () async {
      final responseBytes = Uint8List.fromList([4, 5, 6, 7]);
      final streamedResponse = http.StreamedResponse(
        Stream.value(responseBytes),
        200,
      );

      when(mockClient.send(any)).thenAnswer((_) async => streamedResponse);

      final result = await ApiService.enhanceImage(dummyFile, client: mockClient);

      expect(result, isA<File>());
      expect(await result!.readAsBytes(), responseBytes);
    });

    test('enhanceImage returns null on API failure', () async {
      final streamedResponse = http.StreamedResponse(
        Stream.value(Uint8List.fromList([])),
        500,
      );

      when(mockClient.send(any)).thenAnswer((_) async => streamedResponse);

      final result = await ApiService.enhanceImage(dummyFile, client: mockClient);

      expect(result, isNull);
    });

    test('enhanceImage returns null on Exception', () async {
      when(mockClient.send(any)).thenThrow(Exception('Network Error'));

      final result = await ApiService.enhanceImage(dummyFile, client: mockClient);

      expect(result, isNull);
    });
  });
}
