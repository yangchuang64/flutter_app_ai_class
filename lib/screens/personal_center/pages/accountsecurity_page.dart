
import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutterblingaiplugin/screen/configs/dark_mode_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/common_widget.dart';
import 'package:provider/provider.dart';


class AccountSecurityPage extends StatefulWidget {
  final String title;

  AccountSecurityPage({this.title});

  @override
  State<StatefulWidget> createState() {
    return AccountSecurityPageState();
  }
}

class AccountSecurityPageState extends State<AccountSecurityPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: DarkModeConfig().secondBackgroundColor,
      appBar: CommonPreferredSize(text: '账户安全'),
      body: Container(
        padding: EdgeInsets.fromLTRB(0.0, pxWithPad(10.0), 0.0, 0.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: _buildBindingPhoneNumberRow(context, '绑定手机'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBindingPhoneNumberRow(BuildContext context, String text) {
    return Container(
        height: pxWithPad(53.0),
        color: DarkModeConfig().mainBackgroundColor,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: pxWithPad(20.0)),
              child: Text(
                text,
                style: CustomTextStyle.fz(fontSize: fontSizeWithPad(16.0), color: DarkModeConfig().mainTitleColor),
              )),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(right: pxWithPad(10.0)),
            child: Text(_getParentPhoneNumber(),
              style: CustomTextStyle.fz(fontSize: fontSizeWithPad(14.0), color: DarkModeConfig().secondTitleColor),
            ),
          ),
        ]));
  }

  String _getParentPhoneNumber() {
    //LocalDataManager.getInstance().getParentMobile()
    // 取登录用户手机号
    LoginInfo loginfo = Provider.of<LoginUserInfo>(context, listen: false).loginInfo;
    if (loginfo.mobile == null || loginfo.mobile.length < 1) {
      return "未绑定";
    } else {
      return loginfo.mobile;
    }
  }
}
