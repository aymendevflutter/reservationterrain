import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class ImgBBService {
  static const String _baseUrl = AppConfig.imgbbBaseUrl;
  static const String _apiKey = AppConfig.imgbbApiKey;

  Future<String> uploadImage(String imagePath) async {
    try {
      // Check if the path is a URL (already uploaded)
      if (imagePath.startsWith('http')) {
        return imagePath;
      }

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file does not exist: $imagePath');
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'key': _apiKey,
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['url'] != null) {
          return data['data']['url'];
        } else {
          throw Exception('Invalid response from ImgBB: ${response.body}');
        }
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<String>> uploadImages(List<String> imagePaths) async {
    try {
      final List<String> uploadedUrls = [];
      for (final path in imagePaths) {
        try {
          final url = await uploadImage(path);
          uploadedUrls.add(url);
        } catch (e) {
          print('Failed to upload image $path: $e');
          // Continue with other images even if one fails
          continue;
        }
      }
      if (uploadedUrls.isEmpty) {
        throw Exception('Failed to upload any images');
      }
      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  String getOptimizedImageUrl(String url) {
    // ImgBB automatically optimizes images, so we can just return the URL
    return url;
  }
}
