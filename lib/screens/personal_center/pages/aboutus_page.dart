import 'package:flutter/material.dart';
import 'package:flutterblingaiplugin/screen/configs/dark_mode_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/common_widget.dart';
import 'package:package_info/package_info.dart';

class AboutUsPage extends StatefulWidget {
  final String title;

  AboutUsPage({this.title});

  @override
  State<StatefulWidget> createState() {
    return AboutUsPageState();
  }
}

class AboutUsPageState extends State<AboutUsPage> {
  TextEditingController controller;
  String _versionString = "";

  @override
  void initState() {
    super.initState();

    _readLocalVersion().then((version){
      print(version);
      _versionString = version;
      setState(() {});
    });
  }
  /// 读取本地版本信息
  Future<String> _readLocalVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return Future.value(packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkModeConfig().mainBackgroundColor,
      appBar: CommonPreferredSize(
        text: '关于我们',
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: px(50), bottom: px(30)),
                  child: Image.asset(
                    'assets/ai_package/images/personalCenter/logo.webp',
                    width: px(241),
                    height: px(42),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(px(42), px(10), px(20), px(10)),
                    child: Container(
                      padding: const EdgeInsets.all(0.0),
                      child: Image.asset(
                        'assets/ai_package/images/personalCenter/laoyu.webp',
                      ),
                      height: px(180),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(px(40), px(20), px(40), px(32)),
                    child: Container(
                      padding: const EdgeInsets.all(0.0),
                      child: Text('比邻东方是新东方旗下独资在线外教直播公司，根据新东方23年教学体系反馈，与国际资深教材编写团队共同打造国际小学课程体系，为5-12岁中国学生量身定做国际小学3人在线外教课程。', style: CustomTextStyle.fz(fontSize: fontSizeWithPad(14), height: 1.8, color: Color(0xFF4a4a4a))),
                      width: MediaQuery.of(context).size.width,
                      height: px(180),
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(px(20), px(10), px(20), px(10)),
                  child: Container(
                    padding: const EdgeInsets.all(0.0),
                    child: Center(
                      child: Text('版本号: V${_versionString}', style: CustomTextStyle.fz(fontSize: fontSizeWithPad(12), color: Colors.grey)),
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
