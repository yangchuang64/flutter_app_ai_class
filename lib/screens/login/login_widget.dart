import 'dart:async';

import 'package:blingabc_base/blingabc_base.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 验证码登陆
class LoginValidFormWidget extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController smsCodeController;

  final Future Function(String phone) onSendSms;
  final Function(String phone, String smsCode) onLogin;
  final Function(String) onNotReceivePhoneCode;

  const LoginValidFormWidget({Key key, this.phoneController, this.smsCodeController, this.onSendSms, this.onLogin, this.onNotReceivePhoneCode}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginValidFormWidgetState();
}

class LoginValidFormWidgetState extends State<LoginValidFormWidget> {
  Function _countDownStartCallback; // 获取验证码，开始启动计时器的函数

  GlobalKey<CountDownState> countDownKey = new GlobalKey<CountDownState>();

  FocusNode phoneFocusNode;
  FocusNode smsFocusNode;

  @override
  void initState() {
    super.initState();
    phoneFocusNode = FocusNode();
    smsFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    phoneFocusNode.dispose();
    smsFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ContainerWithBackground(
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: widget.phoneController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
//                      onSaved: (val) => _loginViewModel.loginState.phone = val,
                  style: CustomTextStyle.fz(),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: CustomTextStyle.fz(color: const Color(0xFFC2C2C2)),
                    hintText: '请输入报名手机号',
                  ),
                  focusNode: phoneFocusNode,
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
        ContainerWithBackground(
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: widget.smsCodeController,
                  keyboardType: TextInputType.number,
//                      onSaved: (val) {
//                        _loginViewModel.loginState.validCode = val;
//                      },
//                      onFieldSubmitted: (val) {
//                        _checkIfComfirmByValidCode();
//                      },
                  style: CustomTextStyle.fz(),
                  // 设置字体样式
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: CustomTextStyle.fz().copyWith(color: const Color(0xFFC2C2C2)),
                    hintText: '短信验证码',
                  ),
                  focusNode: smsFocusNode,
                  onChanged: (value) => setState(() {}),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  left: 8.0,
                  top: 3.0,
                  bottom: 3.0,
                  right: 8.0,
                ),
                height: 30.0,
                child: CountDownWidget(
                  key: countDownKey,
                  verifyStr: '获取验证码',
                  enableTS: CustomTextStyle.fz(fontSize: 14, color: const Color(0xFF999999)),
                  disableTS: CustomTextStyle.fz(fontSize: 14, color: const Color(0xFFCCCCCC)),
                  onTapCallback: _getPhoneCodeEvent,
                  isEnable: widget.phoneController.text.isNotEmpty,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
        ),
        ShapeButton(
          title: '登录',
          isEnable: widget.phoneController.text.isNotEmpty && widget.smsCodeController.text.isNotEmpty,
          beginColor: Color(0xFFFABE00),
          endColor: Color(0xFFFABE00),
          onTap: debounce(
            () {
              phoneFocusNode.unfocus();
              smsFocusNode.unfocus();
              widget.onLogin(widget.phoneController.text.trim(), widget.smsCodeController.text.trim());
            },
            500,
          ),
        ),
        SizedBox(
          height: 10,
        ),
//        Center(
//          child: GestureDetector(
//            onTap: _handleCanNotReceivePhoneCodeEvent,
//            child: Text(
//              "收不到验证码？",
//              style: CustomTextStyle.fz().copyWith(fontSize: 15, color: Color(0xFFFABE00)),
//            ),
//          ),
//        ),
      ],
    );
  }

  void _getPhoneCodeEvent(startTimerFunction) {
//    if (_smsCountDownFlag) {
//      UiUtil.showToast("正在处理，请稍后再试");
//      return;
//    }
    Connectivity().checkConnectivity().then((res) {
      if (res == ConnectivityResult.none) {
        UiUtil.showToast("网络未连接");
        return;
      }
//      final form = _validFormKey.currentState;
//      form.save();
//      if (null != _loginViewModel.loginState.phone && Validators.phone(_loginViewModel.loginState.phone)) {
//        _smsCountDownFlag = !_smsCountDownFlag;
//        _countDownStartCallback = startTimerFuncation;
//        _showCodeConfirm();
//      } else {
//        UiUtil.showToast('请输入正确的手机号');
//      }
      if (!Validators.phone(widget.phoneController.text)) {
        UiUtil.showToast('请输入正确的手机号');
        return;
      }
      _countDownStartCallback = startTimerFunction;

      widget.onSendSms(widget.phoneController.text).then((value) {
        _countDownStartCallback();
      }).catchError((error) {
        UiUtil.showToast(error ?? "");
      });
//      var url = sprintf(ApiConfigs.sms_send, [widget.phoneController.text]);
//      print('ai_log url $url');
//      VerificationCode.showWebDialog(context, url, scrollWebVerificationCodeAction);
    });
  }

//  /// Web滑块验证码
//  void scrollWebVerificationCodeAction() {
//    widget.onSendSms(widget.phoneController.text);
//    _countDownStartCallback();
//  }

  /// 收不到验证码 --- 弹窗
  void _handleCanNotReceivePhoneCodeEvent() {
//    if (_smsCountDownFlag) {
//      UiUtil.showToast("正在处理，请稍后再试");
//      return;
//    }
//    final form = _validFormKey.currentState;
//    form.save();
    String phone = widget.phoneController.text.trim();
    if (!Validators.phone(phone)) {
      UiUtil.showToast('请输入正确的手机号码');
      return;
    }
    VerificationCode.showVoiceDialog(context, () => widget.onNotReceivePhoneCode(phone));
  }

  startTimer() {
    countDownKey.currentState.startTimer();
  }

//  showSmsSendDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return Material(
//          type: MaterialType.transparency,
//          child: Center(
//            child: Stack(
//              alignment: AlignmentDirectional(0, -1.45),
//              overflow: Overflow.visible,
//              children: <Widget>[
//                Container(
//                  decoration: BoxDecoration(
//                    color: Color(0xFFFFFFFF),
//                    borderRadius: BorderRadius.all(Radius.circular(10)),
//                  ),
//                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
//                  child: Stack(
//                    alignment: AlignmentDirectional.topEnd,
//                    children: <Widget>[
//                      Column(
//                        mainAxisSize: MainAxisSize.min,
//                        children: <Widget>[
//                          SizedBox(
//                            height: 30.0,
//                          ),
//                          Text(
//                            '请根据提示完成验证',
//                            style: CustomTextStyle.fz(fontSize: 18.0, fontStyle: FontStyle.normal, color: Color(0xFF333333)),
//                          ),
//                          Container(
//                            constraints: BoxConstraints(maxWidth: 400.0),
//                            height: 150,
////                            child: _VerifyCodeLoad(
////                              url: url,
////                              successCallback: successCallback,
////                            ),
//                          ),
//                          SizedBox(
//                            height: 15,
//                          )
//                        ],
//                      ),
//                      GestureDetector(
////                        onTap: extraCancel,
//                        child: Padding(
//                          padding: EdgeInsets.all(15.0),
//                          child: Icon(
//                            Icons.cancel,
//                            size: 24.0,
//                            color: Colors.black38,
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Container(
//                  width: 60,
//                  height: 60,
//                  child: Image.asset("assets/ai_package/images/login/coco_alert_icon.webp"),
//                ),
//              ],
//            ),
//          ),
//        );
//      },
//    );
//  }
}

/// 密码登陆wighet
class LoginPasswordFormWidget extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;

  final Function(String, String) onLogin;
  final Function() onForgetPassword;

  const LoginPasswordFormWidget({
    Key key,
    this.phoneController,
    this.passwordController,
    this.onLogin,
    this.onForgetPassword,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginPasswordFormWidgetState();
  }
}

class _LoginPasswordFormWidgetState extends State<LoginPasswordFormWidget> {
  var isPasswordVisible = false;

  FocusNode phoneFocusNode;
  FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    phoneFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ContainerWithBackground(
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: widget.phoneController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  style: CustomTextStyle.fz(),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: CustomTextStyle.fz().copyWith(color: new Color(0xFFC2C2C2)),
                    hintText: '请输入报名手机号',
                  ),
                  focusNode: phoneFocusNode,
                  onChanged: (value) => setState(() {}),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
        ContainerWithBackground(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: TextFormField(
                    controller: widget.passwordController,
                    keyboardType: TextInputType.text,
                    style: CustomTextStyle.fz(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: CustomTextStyle.fz().copyWith(color: new Color(0xFFC2C2C2)),
                      hintText: '请输入密码',
                    ),
                    obscureText: !isPasswordVisible,
                    focusNode: passwordFocusNode,
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => isPasswordVisible = !isPasswordVisible),
                child: isPasswordVisible ? Image(image: AssetImage('assets/ai_package/images/login/eye_open.webp'), width: 18, height: 18) : Image(image: AssetImage('assets/ai_package/images/login/eye_close.webp'), width: 18, height: 18),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          '密码同新东方中小学手机号登录密码',
          style: CustomTextStyle.fz().copyWith(color: new Color(0xFFC2C2C2)),
        ),
        SizedBox(
          height: 54,
        ),
        ShapeButton(
          title: '登录',
          isEnable: widget.phoneController.text.isNotEmpty && widget.passwordController.text.isNotEmpty,
          beginColor: Color(0xFFFABE00),
          endColor: Color(0xFFFABE00),
          onTap: () {
            phoneFocusNode.unfocus();
            passwordFocusNode.unfocus();
            widget.onLogin(widget.phoneController.text.trim(), widget.passwordController.text.trim());
          },
        ),
        SizedBox(
          height: 10,
        ),
//        Center(
//          child: GestureDetector(
//            child: Text('  忘记密码?  ', style: CustomTextStyle.fz().copyWith(fontSize: 16, color: Color(0xFFFABE00))),
//            onTap: widget.onForgetPassword,
//          ),
//        ),
      ],
    );
  }
}

/// 登陆相关，输入框背景
class ContainerWithBackground extends StatelessWidget {
  final Widget child;

  const ContainerWithBackground({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: ShapeDecoration(
        color: Color(0xFFf8f8f8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),
      child: child,
    );
  }
}

//// 按钮，登陆功能按钮
//class ShapeButton extends StatelessWidget {
//  final title;
//  final Function() onTap;
//  final isEnable;
//
//  const ShapeButton({Key key, this.title, this.onTap, this.isEnable = true}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return GestureDetector(
//      onTap: isEnable ? onTap : null,
//      child: Stack(
//        children: <Widget>[
//          Container(
//            decoration: BoxDecoration(
//              color: Color(0xFFf8f8f8),
//              borderRadius: BorderRadius.all(Radius.circular(48.0)),
//              gradient: LinearGradient(
//                colors: [Color(0xFFFABE00), Color(0xFFFABE00)],
//                begin: FractionalOffset(0, 1),
//                end: FractionalOffset(1, 0),
//              ),
//            ),
//            child: Container(
//              height: 48,
//              width: double.infinity,
//              alignment: Alignment.center,
//              child: Text(
//                title,
//                style: CustomTextStyle.fz().copyWith(
//                  fontSize: 18.0, //字体大小
//                  color: isEnable ? const Color(0xffffffff) : const Color(0x88ffffff), //文字颜色
//                ),
//              ),
//            ),
//          ),
//          Positioned(
//            top: 2,
//            child: Image(
//              image: AssetImage('assets/ai_package/images/login/button_light_left.webp'),
//              width: 28,
//            ),
//          ),
//          Positioned(
//            right: 3,
//            bottom: 3,
//            child: Image(
//              image: AssetImage('assets/ai_package/images/login/button_light_right.webp'),
//              width: 12,
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//}
