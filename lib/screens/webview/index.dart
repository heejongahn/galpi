import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebviewArgument {
  final String title;
  final String link;

  WebviewArgument(this.title, this.link);
}

class Webview extends StatefulWidget {
  final WebviewArgument args;

  const Webview({Key key, this.args}) : super(key: key);

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  WebViewController _controller;
  String _title = '';

  @override
  Widget build(BuildContext context) {
    final link = widget.args.link;
    final linkWithProtocol = link.startsWith('http://')
        ? link
        : link.startsWith('https://') ? link : 'https://${link}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.title != '' ? widget.args.title : _title,
        ),
      ),
      body: WebView(
        onWebViewCreated: (WebViewController controller) async {
          _controller = controller;
        },
        onPageFinished: (_) async {
          if (_controller == null) {
            return;
          }

          final title = await _controller.getTitle();
          setState(() {
            _title = title;
          });
        },
        initialUrl: linkWithProtocol,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
