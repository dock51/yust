import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share/share.dart';
import 'package:yust/yust.dart';

class ImageScreen extends StatelessWidget {
  static const String routeName = '/imageScreen';

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    String? url;
    List<String>? urls;

    if (arguments is Map) {
      url = arguments['url'];
      final urlsArgs = arguments['urls'];

      if (urlsArgs is List) {
        urls = urlsArgs.whereType<String>().toList();
      }
    }
    if (urls != null) {
      return _buildMultiple(context, urls, url);
    } else {
      return _buildSingle(context, url!);
    }
  }

  Widget _buildSingle(BuildContext context, String url) {
    return Stack(children: [
      Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
          minScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag: url),
          onTapUp: (context, details, controllerValue) {
            Navigator.pop(context);
          },
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
      _buildShareButton(context, url),
    ]);
  }

  Widget _buildMultiple(
      BuildContext context, List<String> urls, String? activeUrl) {
    int firstPage = 0;
    if (activeUrl != null) {
      firstPage = urls.indexOf(activeUrl);
    }
    PageController _pageController = PageController(initialPage: firstPage);
    return Stack(
      children: [
        Container(
          child: PhotoViewGallery.builder(
            itemCount: urls.length,
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: _pageController,
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(urls[index]),
                minScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: urls[index]),
                onTapUp: (context, details, controllerValue) {
                  Navigator.pop(context);
                },
              );
            },
            loadingBuilder: (context, event) => Center(
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(),
              ),
            ),
            // backgroundDecoration: widget.backgroundDecoration,
            // onPageChanged: onPageChanged,
          ),
        ),
        _buildShareButton(context, activeUrl!),
        if (kIsWeb)
          Container(
            padding: const EdgeInsets.all(20.0),
            alignment: Alignment.topRight,
            child: CircleAvatar(
              backgroundColor: Colors.black,
              radius: 25,
              child: IconButton(
                iconSize: 35,
                color: Colors.white,
                icon: Icon(
                  Icons.arrow_back_ios_new,
                ),
                onPressed: () {
                  _pageController.previousPage(
                    duration: new Duration(milliseconds: 500),
                    curve: Curves.easeOutSine,
                  );
                },
              ),
            ),
          ),
        if (kIsWeb)
          Container(
            padding: const EdgeInsets.all(20.0),
            alignment: Alignment.centerRight,
            child: CircleAvatar(
              backgroundColor: Colors.black,
              radius: 25,
              child: IconButton(
                iconSize: 35,
                color: Colors.white,
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  _pageController.nextPage(
                    duration: new Duration(milliseconds: 500),
                    curve: Curves.easeOutSine,
                  );
                },
              ),
            ),
          ),
        if (kIsWeb)
          Container(
            padding: const EdgeInsets.all(20.0),
            alignment: Alignment.topRight,
            child: CircleAvatar(
              backgroundColor: Colors.black,
              radius: 25,
              child: IconButton(
                iconSize: 35,
                color: Colors.white,
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context, String url) {
    return Positioned(
      top: 0.0,
      right: 50.0,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.topRight,
        child: IconButton(
          iconSize: 35,
          color: Colors.white,
          onPressed: () =>
              {(kIsWeb) ? _downloadImage(url) : _shareFile(context, url)},
          icon: (kIsWeb) ? Icon(Icons.download) : Icon(Icons.share),
        ),
      ),
    );
  }

  Future<void> _shareFile(BuildContext context, String url) async {
    final String name = Yust.service.randomString() + '.jpg';
    if (true) {
      await EasyLoading.show(status: 'Datei laden...');
      try {
        final tempDir = await getTemporaryDirectory();
        await Dio().download(url, '${tempDir.path}/' + name);
        await Share.shareFiles(['${tempDir.path}/' + name], subject: name);
        await EasyLoading.dismiss();
      } catch (e) {
        await EasyLoading.dismiss();
        await Yust.service.showAlert(context, 'Ups',
            'Die Datei kann nicht geöffnet werden. ${e.toString()}');
      }
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      final http.Response r = await http.get(
        Uri.parse(imageUrl),
      );
      final data = r.bodyBytes;
      final base64data = base64Encode(data);
      final a = html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');
      a.download = 'download.jpg';
      a.click();
      a.remove();
    } catch (e) {
      print(e);
    }
  }
}
