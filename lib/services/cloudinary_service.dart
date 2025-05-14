import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../core/config/app_config.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinary;

  CloudinaryService()
      : _cloudinary = CloudinaryPublic(
          AppConfig.cloudinaryCloudName,
          AppConfig.cloudinaryUploadPreset,
        );

  Future<String> uploadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<String>> uploadImages(List<String> imagePaths) async {
    try {
      final List<String> uploadedUrls = [];
      for (final path in imagePaths) {
        final url = await uploadImage(path);
        uploadedUrls.add(url);
      }
      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  String getImageUrl(
    String publicId, {
    int? width,
    int? height,
    String? format,
    bool optimized = true,
  }) {
    var transformation = '';

    if (width != null) transformation += 'w_$width,';
    if (height != null) transformation += 'h_$height,';
    if (format != null) transformation += 'f_$format,';
    if (optimized) transformation += 'q_auto,f_auto,';

    if (transformation.isNotEmpty) {
      transformation = transformation.substring(0, transformation.length - 1);
    }

    return 'https://res.cloudinary.com/${AppConfig.cloudinaryCloudName}/image/upload' +
        (transformation.isNotEmpty ? '/$transformation' : '') +
        '/$publicId';
  }

  String getOptimizedImageUrl(String url) {
    if (!url.contains('cloudinary.com')) return url;

    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final uploadIndex = pathSegments.indexOf('upload');

    if (uploadIndex == -1) return url;

    final publicId = pathSegments.sublist(uploadIndex + 1).join('/');
    return getImageUrl(publicId, optimized: true);
  }
}
