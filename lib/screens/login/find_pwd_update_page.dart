import 'package:blingabc_base/blingabc_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/screens/login/view_model/login/findpwd_update_view_model.dart';

///更新密码
class UpdatePasswordPage extends StatefulWidget {
  final String phoneNumber;
  final String phoneCodeNumber;

  UpdatePasswordPage(this.phoneNumber, this.phoneCodeNumber);

  @override
  State<StatefulWidget> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePasswordPage> {
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _passwordConfirmController = new TextEditingController();

  var isPasswordEyeOpen = false;
  var isPasswordConfirmEyeOpen = false;

  FindpwdUpdateViewModel _findpwdUpdateViewModel = FindpwdUpdateViewModel();

  @override
  void initState() {
    super.initState();
    // 禁止转屏幕
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: new ThemeData(
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
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("重新设置密码", style: CustomTextStyle.fz(fontSize: 21)),
                      SizedBox(
                        height: 30,
                      ),
                      ContainerWithBackground(
                        child: Row(
                          children: [
                            Expanded(child: TextFormField(controller: _passwordController, textInputAction: TextInputAction.next, keyboardType: TextInputType.text, style: CustomTextStyle.fz(color: Color(0xFF000000)), obscureText: !isPasswordEyeOpen, decoration: InputDecoration(border: InputBorder.none, hintStyle: CustomTextStyle.fz(color: Color(0xFFC2C2C2)), hintText: '请输入新密码'))),
                            GestureDetector(
                              onTap: () => setState(() => isPasswordEyeOpen = !isPasswordEyeOpen),
                              child: isPasswordEyeOpen ? Image(image: AssetImage('assets/ai_package/images/login/eye_open.webp'), width: 18, height: 18) : Image(image: AssetImage('assets/ai_package/images/login/eye_close.webp'), width: 18, height: 18),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      ContainerWithBackground(
                        child: Row(
                          children: [
                            Expanded(child: TextFormField(controller: _passwordConfirmController, textInputAction: TextInputAction.next, keyboardType: TextInputType.text, style: CustomTextStyle.fz(color: Color(0xFF000000)), obscureText: !isPasswordConfirmEyeOpen, decoration: InputDecoration(border: InputBorder.none, hintStyle: CustomTextStyle.fz(color: Color(0xFFC2C2C2)), hintText: '再次输入新密码'))),
                            GestureDetector(
                              onTap: () => setState(() => isPasswordConfirmEyeOpen = !isPasswordConfirmEyeOpen),
                              child: isPasswordConfirmEyeOpen ? Image(image: AssetImage('assets/ai_package/images/login/eye_open.webp'), width: 18, height: 18) : Image(image: AssetImage('assets/ai_package/images/login/eye_close.webp'), width: 18, height: 18),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      ShapeButton(
                        title: '确定',
                        isEnable: true,
                        beginColor: Color(0xFFFABE00),
                        endColor: Color(0xFFFABE00),
                        onTap: _conformToSubmit,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 确定按钮 ，提交密码修改
  void _conformToSubmit() async {
    await SystemChannels.textInput.invokeMethod("TextInput.hide");

    var password = _passwordController.text;
    var confirmPassword = _passwordConfirmController.text;
//    _findpwdUpdateViewModel.updatePassword(
//        widget.phoneNumber, widget.phoneCodeNumber, password, confirmPassword,
//        onError: (error) => UiUtil.showToast(error),
//        onResponse: (respond) {
//          if (respond.result) {
//            UiUtil.showToast("密码修改成功");
//            Future.delayed(Duration(seconds: 1)).then((value) {
//              Navigator.of(context)
//                  .pushNamedAndRemoveUntil(PagePath.login, (Route<dynamic> route) => false);
//            });
//          } else {
//            UiUtil.showToast(respond.msg);
//          }
//        });
    _findpwdUpdateViewModel.updatePassword(widget.phoneNumber, widget.phoneCodeNumber, password, confirmPassword).then((resp) {
      if (resp.result) {
        UiUtil.showToast("密码修改成功");
//        Future.delayed(Duration(seconds: 1)).then((value) {
////          Navigator.of(context).pushNamedAndRemoveUntil(PagePath.login, (Route<dynamic> route) => false);
//        });
        Navigator.pop(context);
      } else {
        UiUtil.showToast(resp?.msg ?? "");
      }
    }).catchError((error) => UiUtil.showToast(error ?? ""));
  }
}
