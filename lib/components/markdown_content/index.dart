import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:galpi/screens/webview/index.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkdownContent extends StatelessWidget {
  final String data;

  const MarkdownContent({final Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return MarkdownBody(
      data: data,
      imageBuilder: (Uri uri, String title, String alt) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 0,
          ),
          child: Image.network(
            uri.toString(),
          ),
        );
      },
      fitContent: false,
      onTapLink: (link) {
        Navigator.of(context).pushNamed(
          '/webview',
          arguments: WebviewArgument('', link),
        );
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        h1: textTheme.headline5.copyWith(
          height: 2,
        ),
        h2: textTheme.headline6.copyWith(
          height: 2,
        ),
        h3: textTheme.subtitle1.copyWith(
          fontWeight: FontWeight.bold,
          height: 2,
        ),
        p: textTheme.bodyText2.copyWith(
          height: 1.6,
        ),
        a: const TextStyle(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
        ),
        listBullet: textTheme.bodyText2.copyWith(
          height: 1,
        ),
        code: GoogleFonts.robotoMono(
          color: Colors.black87,
        ),
        codeblockPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        codeblockDecoration: BoxDecoration(
          border: Border.all(
            color: Colors.black54,
            width: 0.5,
          ),
        ),
        blockquotePadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 24,
        ),
        blockquoteDecoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.black54,
              width: 4,
            ),
          ),
        ),
        // blockSpacing: 16,
      ),
    );
  }
}
