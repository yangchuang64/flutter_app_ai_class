import 'package:blingabc_base/blingabc_base.dart' as Base;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/mixin/GamePage.dart';
import 'package:flutterblingaiplugin/screen/configs/dark_mode_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';

class GameListPage extends StatefulWidget {
  final int id;

  const GameListPage({Key key, this.id}) : super(key: key);

  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(scaffoldBackgroundColor: Colors.white),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _creatNormalTile("弹弓", "", () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GamePage(id: 0)));
            }),
            _creatNormalTile("连线", "", () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GamePage(id: 1)));
            }),
            _creatNormalTile("过桥游戏", "", () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GamePage(id: 2)));
            }),
            _creatNormalTile("单词组句游戏", "", () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GamePage(id: 3)));
            }),
            _creatNormalTile("电视字母填空", "", () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GamePage(id: 4)));
            }),
            _creatNormalTile("饮料游戏", "", () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GamePage(id: 5)));
            }),
          ],
        ),
      ),
    );
  }

  Widget _creatNormalTile(String name, String value, Function callBack) {
    return GestureDetector(
      onTap: callBack,
      child: Container(
        padding: EdgeInsets.only(left: pxWithPad(20), right: pxWithPad(20)),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  name,
                  style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(16)),
                ),
                Expanded(
                  child: Text(""),
                ),
                Text(
                  value ?? "",
                  style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().secondTitleColor, fontSize: fontSizeWithPad(16)),
                ),
                SizedBox(
                  width: pxWithPad(1),
                  height: pxWithPad(52),
                ),
                Image.asset(
                  "assets/ai_package/images/personalCenter/icon_arrow.webp",
                  width: pxWithPad(12),
                  height: pxWithPad(12),
                ),
              ],
            ),
            Container(
              color: DarkModeConfig().dividerColor,
              height: 1.0,
            ),
          ],
        ),
      ),
    );
  }
}
