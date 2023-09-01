import 'package:bling_downloader/bling_downloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/screens/ai_class_detail/ai_preview_page.dart';
import 'package:flutter_app_ai_math/screens/login/login_page.dart';
import 'package:flutter_app_ai_math/screens/personal_center/pages/accountsecurity_page.dart';
import 'package:flutter_app_ai_math/screens/personal_center/widgets/three_tap_button.dart';
import 'package:flutter_app_ai_math/screens/upgradeController/upgrade_controller.dart';
import 'package:flutterblingaiplugin/screen/configs/dark_mode_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/shared_preferences.dart';
import 'package:flutterblingaiplugin/screen/uitils/storage.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/common_widget.dart';
import 'package:flutterblingaiplugin/screen/widgets/dialogs.dart';
import 'package:protect_eye/protect_eye.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';

class SettingPages extends StatefulWidget {
  final String title; // 用来储存传递过来的值
  SettingPages({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingPagesState();
  }
}

class SettingPagesState extends State<SettingPages> with WidgetsBindingObserver {
  var leftRightPadding = 30.0;
  var topBottomPadding = 4.0;
  bool _switchValue;

  bool _darkModeValue = false;
  String _versionString = "";

  @override
  void initState() {
    UiUtil.setPortraitUpMode();
    super.initState();

    DarkModeConfig().readLocalModeData().then((value) {
      _darkModeValue = value;
      setState(() {});
    });
    _readLocalVersion().then((version){
      _versionString = version;
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      if (mounted == false) return;
      SpUtil.getInstance().then((spl) {
        _switchValue = spl.getBool("protectModel");
        setState(() {});
      });
    });
  }

  /// 清理缓存
  void _clearCache() async {
    bool resp = await showIosStyleAlertDialog(context, title: "确定要清理所有缓存?", content: "课程缓存文件清理后,资源文件需要重新下载");
    if (resp == true) {
      await BlingDownloader.clearCache(day: 0);
      UiUtil.showToast("清理完成");
    }
  }

  /// 版本升级
  void _updateApp(){
    UpgradeController.checkUpgrade(context,showAlreadyUpdated: true);
  }

  /// 读取本地版本信息
  Future<String> _readLocalVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return Future.value(packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkModeConfig().secondBackgroundColor,
      appBar: CommonPreferredSize(text: "设置",actions: <Widget>[
        ThreeTapButton(
          callBack: () {
            Navigator.push<String>(context, MaterialPageRoute(builder: (BuildContext context) {
              return AiPreviewPage();
            }));
          },
        ),
      ],),
      body: Container(
        padding: EdgeInsets.fromLTRB(0.0, pxWithPad(10.0), 0.0, 0.0),
        child: ListView(
          children: <Widget>[
            GestureDetector(
              child: _buildAboutusRow(context, '账户安全', true),
              onTap: () {
                Navigator.push<String>(context, MaterialPageRoute(builder: (BuildContext context) {
                  return AccountSecurityPage();
                }));
              },
            ),
            GestureDetector(
              child: _buildSafetyRow(context, '护眼模式', isArrow: false),
            ),
            SizedBox(height: pxWithPad(20.0)),
            GestureDetector(
              child: _buildAboutusRow(context, "清理缓存", true),
              onTap: _clearCache,
            ),
            GestureDetector(
              child: _buildCheckUpdateRow(context, '检查更新'),
              onTap: _updateApp,
            ),
            _buildDarkModeRow(context),
//            GestureDetector(
//              child: _buildAboutusRow(context, '关于我们', false),
//              onTap: () {
//                Navigator.push<String>(context, MaterialPageRoute(builder: (BuildContext context) {
//                  return AboutUsPage();
////                  return AboutusWebPage();
//                }));
//              },
//            ),
            _buildLogoutBtn(context, leftRightPadding, topBottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyRow(BuildContext context, String text, {bool isArrow = true}) {
    return Container(
      height: pxWithPad(82),
      color: DarkModeConfig().mainBackgroundColor,
      padding: EdgeInsets.only(right: pxWithPad(10), top: pxWithPad(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: pxWithPad(20.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text,
                  style: CustomTextStyle.fz(fontSize: fontSizeWithPad(16), color: DarkModeConfig().mainTitleColor),
                ),
                Padding(
                  padding: EdgeInsets.only(top: pxWithPad(8), bottom: pxWithPad(8)),
                  child: Text(
                    "开启后，可降低蓝光对眼睛的伤害",
                    style: CustomTextStyle.fz(color: DarkModeConfig().secondTitleColor, fontSize: fontSizeWithPad(14)),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(pxWithPad(5)),
            child: _buildSwitchButton(),
          )
        ],
      ),
    );
  }

  Widget _buildSwitchButton() {
    return CupertinoSwitch(
      value: _switchValue ?? false,
      onChanged: (bool value) {
        setState(() {
          _switchValue = value;
          SpUtil.getInstance().then((spl) {
            spl.putBool("protectModel", _switchValue);
            ProtectEye.setProtectModel(_switchValue);
//            FlutterUmeng.setProtectModel(_switchValue);
          });
        });
      },
    );
  }

  Widget _buildAboutusRow(BuildContext context, String text, bool showDivider) {
    return Container(
        height: pxWithPad(53),
        color: DarkModeConfig().mainBackgroundColor,
        padding: EdgeInsets.only(left: pxWithPad(20)),
        child: Column(
          children: <Widget>[
            Container(
              height: pxWithPad(52),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    text,
                    style: CustomTextStyle.fz(fontSize: fontSizeWithPad(16), color: DarkModeConfig().mainTitleColor),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: pxWithPad(20)),
                    child: Image.asset(
                      'assets/ai_package/images/personalCenter/icon_arrow.webp',
                      width: pxWithPad(12),
                      height: pxWithPad(12),
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: (showDivider ? 1 : 0),
              color: (showDivider ? DarkModeConfig().dividerColor : Colors.white),
            )
          ],
        ));
  }

  Widget _buildDarkModeRow(BuildContext context) {
    return Container(
        height: pxWithPad(53),
        color: DarkModeConfig().mainBackgroundColor,
        padding: EdgeInsets.only(left: pxWithPad(20)),
        child: Column(
          children: <Widget>[
            Container(
              height: pxWithPad(52),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "开启夜间模式",
                    style: CustomTextStyle.fz(fontSize: fontSizeWithPad(16), color: DarkModeConfig().mainTitleColor),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: pxWithPad(20)),
                    child: CupertinoSwitch(
                      value: _darkModeValue ?? false,
                      onChanged: _didSwitchDarkModel,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: DarkModeConfig().dividerColor,
            )
          ],
        ));
  }

  void _didSwitchDarkModel(bool value) async {
    _darkModeValue = value;

    StorageKey key = StorageKey.custom(key: "darkModel", valueType: bool);
    await Storage.setBool(key, _darkModeValue);
    DarkModeConfig().isDartMode = _darkModeValue;
    setState(() {});
    //
  }

  Widget _buildCheckUpdateRow(BuildContext context, String text){

    return Container(
        height: pxWithPad(53),
        color: DarkModeConfig().mainBackgroundColor,
        padding: EdgeInsets.only(left: pxWithPad(20)),
        child: Column(
          children: <Widget>[
            Container(
              height: pxWithPad(52),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    text,
                    style: CustomTextStyle.fz(fontSize: fontSizeWithPad(16), color: DarkModeConfig().mainTitleColor),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: pxWithPad(10.0)),
                    child: Text(
                      _versionString ?? '',
                      style: CustomTextStyle.fz(fontSize: fontSizeWithPad(16), color: Color(0xFF333333)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: pxWithPad(5), bottom: pxWithPad(5), right: pxWithPad(20)),
                    child: Image.asset(
                      'assets/ai_package/images/personalCenter/icon_arrow.webp',
                      width: pxWithPad(12),
                      height: pxWithPad(12),
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: DarkModeConfig().dividerColor,
            )
          ],
        ));
  }

  Widget _buildLogoutBtn(BuildContext context, var leftRightPadding, var topBottomPadding) {
    return GestureDetector(
      child: Container(
          height: pxWithPad(44),
          margin: EdgeInsets.fromLTRB(pxWithPad(20), pxWithPad(100.0), pxWithPad(20), pxWithPad(20)),
          padding: EdgeInsets.fromLTRB(leftRightPadding, topBottomPadding, leftRightPadding, topBottomPadding),
          decoration: BoxDecoration(
//              color: Color.fromRGBO(117, 94, 251, 1.0),
              color: Colors.amber,
              borderRadius: BorderRadius.all(Radius.circular(pxWithPad(22)))),
          child: Center(
              child: Text(
            "退出登录",
            style: CustomTextStyle.fz(color: DarkModeConfig().mainBackgroundColor, fontSize: fontSizeWithPad(18)),
          ))),
      onTap: () async {
//        print("退出登录");
        bool confirm = await showIosStyleAlertDialog(context, title: "退出登录", content: "您是否要退出当前账号?");
        if (confirm == true) {
          Provider.of<LoginUserInfo>(context).clearLoginInfo();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
        }
      },
    );
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    if (brightness == Brightness.dark) {
      _darkModeValue = true;
      DarkModeConfig().isDartMode = _darkModeValue;
    } else {
      _darkModeValue = false;
      DarkModeConfig().isDartMode = _darkModeValue;
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
