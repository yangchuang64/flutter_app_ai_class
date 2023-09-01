import 'dart:async';

import 'package:blingabc_base/blingabc_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/screens/classesPath/path_page.dart';
import 'package:flutter_app_ai_math/screens/login/find_pwd_page.dart';
import 'package:flutter_app_ai_math/screens/login/switch_student.dart';
import 'package:flutter_app_ai_math/screens/login/view_model/login/login_view_model.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/local_data.dart';
import 'package:fluttergeetestplugin/fluttergeetestplugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../routers/router_config.dart';
import 'login_widget.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController smsCodeController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  GlobalKey<LoginValidFormWidgetState> loginValidKey = new GlobalKey<LoginValidFormWidgetState>();

  final LoginViewModel _loginViewModel = LoginViewModel(); // 登录逻辑类

  bool isLoginByPasswordFlag = false;
  bool protocolChecked = false;

  @override
  void initState() {
    super.initState();
    protocolChecked = local_data_get(LOCAL_DATA_LOGIN_PROTOCOL) ?? false;
//    print('ai_log login protocolChecked:${protocolChecked}');
    permissionCheck();
    _landscapeSet();
  }

  /// 竖屏设置
  void _landscapeSet() async {
    if (UiUtil.isLandscape() == true) {
      await SystemChrome.setEnabledSystemUIOverlays([]);
      await UiUtil.setPortraitUpMode();
    }
  }

  Future permissionCheck() {
    return PermissionHandler().requestPermissions([
      PermissionGroup.storage,
    ]);
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
            _buildHeader(),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                child: Column(
                  children: <Widget>[
                    _buildSwitchLogin(),
                    SizedBox(
                      height: 30.0,
                    ),
                    isLoginByPasswordFlag
                        ? LoginPasswordFormWidget(
                            phoneController: phoneController,
                            passwordController: passwordController,
                            onLogin: _loginWithPassword,
                            onForgetPassword: _forgetPassword,
                          )
                        : LoginValidFormWidget(
                            key: loginValidKey,
                            phoneController: phoneController,
                            smsCodeController: smsCodeController,
                            onSendSms: _sendSms,
                            onLogin: _loginWithSmsCode,
                            onNotReceivePhoneCode: _requestPhoneCallbackCode,
                          ),
                    Spacer(),
//                  _buildOtherLoginWay(
//                    isWeChatInstalled: _loginViewModel.isWeChatInstalled,
//                    onWxLoginTop: _wxLoginAction,
//                    onXdfLogin: _xdfStudentLogin,
//                    onCallServicePhone: _callServicePhoneNumber,
//                  ),
//                  Container(height: 20),
                    _buildProtocol(
                      onUserProtoTap: () => UserProtocolDialog.showUserProtocolDialog(this.context),
                      onPrivateTap: () => PrivacyProtocolDialog.show(this.context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
//    return;
  }

  Widget _buildHeader() {
    return Stack(
      alignment: const AlignmentDirectional(0.0, 0.9),
      children: <Widget>[
        Container(
          color: Color(0xFFFABE00),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image(
                height: 130.0,
                image: AssetImage('assets/ai_package/images/login/background.webp'),
                fit: BoxFit.fitHeight,
              ),
              Container(
                height: 13.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13.0),
                    topRight: Radius.circular(13.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        Image(
          image: AssetImage(isLoginByPasswordFlag ? 'assets/ai_package/images/login/coco_look_right.webp' : 'assets/ai_package/images/login/coco_look_left.webp'),
          height: 70,
          width: 90,
        ),
      ],
    );
  }

  Widget _buildSwitchLogin() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.only(right: 20.0),
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => setState(() => isLoginByPasswordFlag = false),
              child: Text(
                '验证码登录',
                style: CustomTextStyle.fz().copyWith(
                  fontSize: 20.0,
                  color: !isLoginByPasswordFlag ? const Color(0xFF4a4a4a) : const Color(0xFFCCCCCC),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 1.0,
          height: 16.0,
          color: const Color(0xFFCCCCCC),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 20.0),
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => setState(() => isLoginByPasswordFlag = true),
              child: Text(
                '密码登录',
                style: CustomTextStyle.fz().copyWith(
                  fontSize: 20.0,
                  color: isLoginByPasswordFlag ? const Color(0xFF4a4a4a) : const Color(0xFFCCCCCC),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 协议
  Widget _buildProtocol({Function() onUserProtoTap, Function() onPrivateTap}) {
    TextStyle textStyle = CustomTextStyle.fz().copyWith(fontSize: 12.0, color: const Color(0xff919191));
    TextStyle clickableTextStyle = CustomTextStyle.fz().copyWith(fontSize: 12.0, color: const Color(0xFFFABE00));

    BoxDecoration underline = BoxDecoration(
      border: Border(bottom: BorderSide(width: 1.0, color: Color(0xff919191))),
    );
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () => setState(() {
              protocolChecked = !protocolChecked;
              local_data_put(LOCAL_DATA_LOGIN_PROTOCOL, protocolChecked);
            }),
            child: Container(
              padding: EdgeInsets.all(5),
              child: protocolChecked
                  ? Icon(
                      Icons.check_circle,
                      size: 20,
                      color: const Color(0xFFFABE00),
                    )
                  : Icon(
                      Icons.radio_button_unchecked,
                      size: 20,
                      color: const Color(0xFFFABE00),
                    ),
            ),
          ),
          Text('登录即表示同意', style: textStyle),
          GestureDetector(
            child: Text('《bling用户协议》', style: clickableTextStyle),
//              onTap: () => UserProtocolDialog.showUserProtocolDialog(this.context)),
            onTap: onUserProtoTap,
          ),
          GestureDetector(
            child: Text('《隐私政策》', style: clickableTextStyle),
//              onTap: () => PrivacyProtocolDialog.show(this.context)
            onTap: onPrivateTap,
          ),
        ],
      ),
    );
  }

  onLogin(String phone, String password) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PathPage()));
  }

  Future _sendSms(String phone) {
    var completer = Completer();
    Fluttergeetestplugin.launchGeetest(api1: ApiConfigs.registerUrl, api2: ApiConfigs.validateUrl, checkType: 'aiSendSms').then((value) {
      if (value == null) {
//        UiUtil.showToast('安全验证失败!');
        completer.completeError('安全验证失败!');
        return;
      }

      _loginViewModel.sendSms(phone, value).then((value) {
        completer.complete();
      }).catchError((error) {
        completer.completeError(error);
      });
    });
    return completer.future;
  }

  /// 验证码登陆
  void _loginWithSmsCode(String phone, String smsCode) async {
    await SystemChannels.textInput.invokeMethod("TextInput.hide");
//    FocusScope.of(context).unfocus();
    await Future.delayed(Duration(milliseconds: 500));
//    bool isArgee = _loginViewModel.getIfShowSecretState();
    if (!protocolChecked) {
//      PrivacyPolicyDialog.showPrivacyPolicyDialog(this.context, isArgee, () {});
      UiUtil.showToast('请阅读协议并勾选');
      return;
    }

    UiUtil.showCocoDialog(context);

    _loginViewModel.loginWithSmsCode(phone, smsCode).then((userModel) {
      UiUtil.hideCocoDialog(context);
      _jumpWithUserInfo(userModel);
    }).catchError((error) {
      UiUtil.hideCocoDialog(context);
      UiUtil.showToast(error ?? "");
    });
  }

  /// 请求服务端电话回拨告知验证码
  void _requestPhoneCallbackCode(String phoneNum) {
    if (phoneNum.length != 11) {
      UiUtil.showToast("请输入正确手机号");
      return;
    }
    _startDialPhone(phoneNum);
  }

  void _startDialPhone(String phoneNum) {
    UiUtil.showCocoDialog(context, content: '正在请求电话回拨');
//    _loginViewModel.getVerifyCodeByDialPhone(phoneNum).then((BaseResp resp) {
//      UiUtil.hideCocoDialog(context);
//      if (resp.code == HTTP_CODE_SUCCESS) {
//        UiUtil.showToast("请注意接听电话");
//        loginValidKey.currentState.startTimer();
//      } else {
//        UiUtil.showToast(resp.msg);
//      }
//    });
  }

  /// 密码登陆
  void _loginWithPassword(String phone, String password) async {
    await SystemChannels.textInput.invokeMethod("TextInput.hide");
    await Future.delayed(Duration(milliseconds: 500));

    if (!protocolChecked) {
      UiUtil.showToast('请阅读协议并勾选');
      return;
    }

    UiUtil.showCocoDialog(context);
    _loginViewModel.loginWithPassword(phone, password).then((userModel) {
      UiUtil.hideCocoDialog(context);
      _jumpWithUserInfo(userModel);
    }).catchError((error) {
      UiUtil.hideCocoDialog(context);
      UiUtil.showToast(error ?? "");
    });
  }

  /// 忘记密码
  void _forgetPassword() async {
    await SystemChannels.textInput.invokeMethod("TextInput.hide");
    await Future.delayed(Duration(milliseconds: 500));

//    bool isArgee = _loginViewModel.getIfShowSecretState();
//    if (!isArgee) {
//      PrivacyPolicyDialog.showPrivacyPolicyDialog(this.context, isArgee, () {});
//      return;
//    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => FindPwdPage()));
  }

  _jumpWithUserInfo(LoginInfo loginInfo) {
//    if (!Validators.isNotBaby(userModel.studentList[0].enName)) {
//      var result = await Navigator.pushNamed(context, 'PagePath.complete_info') ?? false;
//      if (!result) {
////        UiUtil.clearLoginInfo(context);
//        return;
//      }
//    }

//    if (userModel.parentInfo.initPwdFlag == 1) {
//      // fixme reset
//      await Navigator.pushNamed(context, 'PagePath.reset_password');
//    }
    Provider.of<LoginUserInfo>(context).updateLoginInfo(loginInfo);
    if (loginInfo.studentList == null && loginInfo.studentList.length == 0) {
      UiUtil.showToast("获取到的用户信息有误");
      return;
    }

    _loginViewModel.loginLog(loginInfo.mobile, loginInfo.parentNum);

    if (loginInfo.studentList.length > 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SwitchStudentPage())).then((value) {
        if (value != null && value) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PathPage()), (_) => false);
      });
    } else {
      Provider.of<LoginUserInfo>(context, listen: false).updateSelectedStudent(loginInfo.studentList[0]);
      Navigator.pushNamedAndRemoveUntil(context, PagePath.path, (_) => false);
    }
  }
}
