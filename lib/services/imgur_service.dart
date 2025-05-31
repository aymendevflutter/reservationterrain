import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ImgurService {
  static const String _clientId = '438ce23475c348';
  static const String _baseUrl = 'https://api.imgur.com/3';

  Future<String> uploadImage(File imageFile) async {
    try {
      // Verify file exists and is accessible
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Get file size
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception('Image file is too large (max 10MB)');
      }

      // Read file as bytes with error handling
      List<int> bytes;
      try {
        bytes = await imageFile.readAsBytes();
      } catch (e) {
        print('Error reading file: $e');
        throw Exception('Could not read image file');
      }

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

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data']['link'];
        } else {
          throw Exception(
              'Upload failed: ${data['data']['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      print('Exception in uploadImage: $e'); // Debug print
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
      print('Exception in uploadMultipleImages: $e'); // Debug print
      throw Exception('Error uploading multiple images: $e');
    }
  }
}
