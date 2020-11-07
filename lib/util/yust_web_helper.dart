import 'dart:html' as html;
import 'dart:typed_data';

import 'package:firebase/firebase.dart' as fb;
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

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

  static Future<Uint8List> downloadFile({String path, String name}) async {
    final url = await fb
        .app()
        .storage()
        .refFromURL(Yust.storageUrl)
        .child(path)
        .child(name)
        .getDownloadURL();
    var res = await http.get(url);
    return res.bodyBytes;
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

  static Future<String> getDownloadUrl({String path, String name}) async {
    YustException('Function not implemented');
  }

  static void downloadAndSaveFileByUrl(String url) {
    html.AnchorElement anchorElement = new html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }
}
