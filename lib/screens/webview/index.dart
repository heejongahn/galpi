import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebviewArgument {
  final String title;
  final String link;

  WebviewArgument(this.title, this.link);
}

class Webview extends StatelessWidget {
  final WebviewArgument args;

  const Webview({Key key, this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(args.title)),
      body: WebView(
        initialUrl: args.link,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
