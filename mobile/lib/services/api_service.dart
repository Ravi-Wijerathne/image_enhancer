import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator / desktop
  // Note: if you are running on physical device, you need the actual IP of the machine running the backend.
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<File?> enhanceImage(File imageFile, {http.Client? client}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/enhance'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      http.StreamedResponse streamedResponse;
      if (client != null) {
        streamedResponse = await client.send(request);
      } else {
        streamedResponse = await request.send();
      }
      
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Save the enhanced image to a temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/enhanced_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Failed to enhance image: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during enhance API call: $e');
      return null;
    }
  }
}
