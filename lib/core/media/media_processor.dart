import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MediaProcessor {
  /// Gera thumbnail (~200x200px) e preview (~1080p) para uma FOTO.
  Future<({File thumb, File preview, File original})> processPhoto(File originalFile) async {
    final tempDir = await getTemporaryDirectory();
    final basename = p.basenameWithoutExtension(originalFile.path);

    final thumbPath = p.join(tempDir.path, '${basename}_thumb.jpg');
    final previewPath = p.join(tempDir.path, '${basename}_preview.jpg');

    final thumbResult = await FlutterImageCompress.compressAndGetFile(
      originalFile.absolute.path,
      thumbPath,
      minWidth: 200,
      minHeight: 200,
      quality: 70,
    );

    final previewResult = await FlutterImageCompress.compressAndGetFile(
      originalFile.absolute.path,
      previewPath,
      minWidth: 1080,
      minHeight: 1080,
      quality: 85,
    );

    return (
      thumb: File(thumbResult!.path),
      preview: File(previewResult!.path),
      original: originalFile,
    );
  }

  /// Gera thumbnail e preview para um VÍDEO.
  Future<({File thumb, File preview, File original})> processVideo(File originalFile) async {
    final info = await VideoCompress.compressVideo(
      originalFile.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );

    final thumbFile = await VideoCompress.getFileThumbnail(
      originalFile.path,
      quality: 50,
      position: -1,
    );

    return (
      thumb: thumbFile,
      preview: File(info!.path!),
      original: originalFile,
    );
  }
}
