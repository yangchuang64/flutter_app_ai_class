import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutterblingaiplugin/screen/widgets/common_widget.dart';

class AboutusWebPage extends StatefulWidget {
  @override
  _AboutusWebPageState createState() => _AboutusWebPageState();
}

class _AboutusWebPageState extends State<AboutusWebPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonPreferredSize(
        text: '关于我们',
      ),
      body: WebviewScaffold(
        url: "https://www.baidu.com",
      ),
//      body: WebView(
//        initialUrl: "https://www.baidu.com",
//        javascriptMode: JavascriptMode.unrestricted,
//      ),
    );
  }
}
