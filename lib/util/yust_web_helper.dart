import 'dart:typed_data';

import 'package:firebase/firebase.dart' as fb;
import 'package:mime/mime.dart';
import 'package:yust/util/yust_exception.dart';

import '../yust.dart';

class YustWebHelper {
  static Future<String> uploadFile(
      {String path, String name, Uint8List bytes}) async {
    var metadata = fb.UploadMetadata(
      contentType: lookupMimeType(name),
    );
    fb.StorageReference ref =
        fb.app().storage().refFromURL(Yust.storageUrl).child(path).child(name);
    fb.UploadTask uploadTask = ref.put(bytes, metadata);
    fb.UploadTaskSnapshot taskSnapshot = await uploadTask.future;
    final uri = await taskSnapshot.ref.getDownloadURL();
    return uri.toString();
  }

  static Future<void> downloadFile({String path, String name}) async {
    YustException('Function not implemented');
  }

  static Future<void> deleteFile({String path, String name}) async {
    await fb
        .app()
        .storage()
        .refFromURL(Yust.storageUrl)
        .child(path)
        .child(name)
        .delete();
  }
}
