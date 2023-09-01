import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/common_widget.dart';

class HowToHaveClassPage extends StatefulWidget {
  final String url, title;

  HowToHaveClassPage({this.url, this.title});

  @override
  _HowToHaveClassPageState createState() => _HowToHaveClassPageState();
}

class _HowToHaveClassPageState extends State<HowToHaveClassPage> {
  @override
  void initState() {
    UiUtil.setPortraitUpMode();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(ApiConfigs.howToHaveClass);
    return Scaffold(
      appBar: CommonPreferredSize(
        text: widget.title ?? '如何上课',
      ),
      body: WebviewScaffold(
        url: widget.url ?? ApiConfigs.howToHaveClass,
      ),
    );
  }
}
