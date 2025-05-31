import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgurService {
  static const String _clientId = '438ce23475c348';
  static const String _baseUrl = 'https://api.imgur.com/3';

  Future<String> uploadImage(File imageFile) async {
    try {
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(bytes);

      // Prepare the request
      final response = await http.post(
        Uri.parse('$_baseUrl/image'),
        headers: {
          'Authorization': 'Client-ID $_clientId',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data']['link'];
        } else {
          throw Exception(
              'Upload failed: ${data['data']['error'] ?? 'Unknown error'}');
        }
      } else {
        print('Error response: ${response.body}'); // Debug print
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e'); // Debug print
      throw Exception('Error uploading image: $e');
    }
  }

  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    try {
      List<String> uploadedUrls = [];

      for (var imageFile in imageFiles) {
        final url = await uploadImage(imageFile);
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      throw Exception('Error uploading multiple images: $e');
    }
  }
}
