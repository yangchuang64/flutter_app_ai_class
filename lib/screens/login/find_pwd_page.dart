import 'package:blingabc_base/blingabc_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/screens/login/find_pwd_update_page.dart';
import 'package:flutter_app_ai_math/screens/login/view_model/login/findpwd_getcode_view_model.dart';

/// 找回密码
class FindPwdPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FindPwdPageState();
}

class _FindPwdPageState extends State<FindPwdPage> {
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _smsCodeController = new TextEditingController();

  Function _countDownStartCallback; // 获取验证码，开始启动计时器的函数

  final FindpwdGetcodeViewModel _findpwdGetcodeViewModel = FindpwdGetcodeViewModel();

  @override
  void initState() {
    super.initState();
    // 禁止转屏幕
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Color(0xFFFFFFFF),
        primaryColorDark: Color(0xFFFFFFFF),
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
      ),
      child: _buildScaffold(),
    );
  }

  _buildScaffold() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: true,
        bottom: true,
        child: InputHide(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  top: 10,
                  right: 15,
                  bottom: 10,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
//                  child: Image(
//                    width: 24,
//                    image: AssetImage('assets/ai_package/images/back_gray.webp'),
//                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("找回密码", style: CustomTextStyle.fz(fontSize: 21)),
                      SizedBox(
                        height: 30,
                      ),
                      ContainerWithBackground(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: new TextFormField(
                                controller: _phoneController,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                style: CustomTextStyle.fz(color: new Color(0xFF000000)),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintStyle: CustomTextStyle.fz(color: new Color(0xFFC2C2C2)),
                                  hintText: '手机号码',
                                ),
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
                              child: new TextFormField(
                                controller: _smsCodeController,
                                keyboardType: TextInputType.text,
                                style: CustomTextStyle.fz(color: new Color(0xFF000000)),
                                // 设置字体样式
                                decoration: new InputDecoration(border: InputBorder.none, hintStyle: CustomTextStyle.fz(color: new Color(0xFFC2C2C2)), hintText: '请输入验证码'),
                                obscureText: true,
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
                                verifyStr: '获取验证码',
                                enableTS: CustomTextStyle.fz(fontSize: 14, color: const Color(0xFF999999)),
                                disableTS: CustomTextStyle.fz(fontSize: 14, color: const Color(0xFF999999)),
                                onTapCallback: _startGetPhoneCode,
                                isEnable: _phoneController.text.isNotEmpty,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ShapeButton(
                        title: '下一步',
                        isEnable: _phoneController.text.isNotEmpty && _smsCodeController.text.isNotEmpty,
                        beginColor: Color(0xFFFABE00),
                        endColor: Color(0xFFFABE00),
                        onTap: debounce(
                          _onGetCodeNext,
                          500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 点击获取验证码
  void _startGetPhoneCode(startTimerFunction) {
    _countDownStartCallback = startTimerFunction;

    _findpwdGetcodeViewModel.checkPhoneNumber(_phoneController.text).then((_) => VerificationCode.showWebDialog(context, _phoneController.text, scrollWebVerificationCodeAction)).catchError((error) => UiUtil.showToast(error ?? ""));
  }

  void scrollWebVerificationCodeAction() {
    _countDownStartCallback();
  }

  // 填入验证码后进行下一步事件
  _onGetCodeNext() async {
    await SystemChannels.textInput.invokeMethod("TextInput.hide");

    var phone = _phoneController.text;
    var smsCode = _smsCodeController.text;
    _findpwdGetcodeViewModel.goNext(phone, smsCode).then((_) {
      Map<String, dynamic> routerParams = {
        "phone": phone,
        "code": smsCode,
      };
      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePasswordPage(phone, smsCode))).then((_) {
        Navigator.pop(context);
      });
    }).catchError((error) => UiUtil.showToast(error ?? ""));
  }
}
