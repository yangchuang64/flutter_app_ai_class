//import 'dart:io';
//import 'dart:ui';
//
//import 'package:blingabc_base/blingabc_base.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_app_ai_math/models/login_user_model.dart';
//import 'package:flutter_app_ai_math/screens/classesPath/path_page.dart';
//import 'package:flutter_app_ai_math/screens/login/login_page.dart';
//import 'package:provider/provider.dart';
//
//class SplashPage extends StatefulWidget {
//  @override
//  _SplashPageState createState() => _SplashPageState();
//}
//
//class _SplashPageState extends State<SplashPage> {
//  @override
//  void initState() {
//    super.initState();
//    setStatusBar();
//
//    /// 横屏设置
//    SystemChrome.setEnabledSystemUIOverlays([]);
//    UiUtil.setPortraitUpMode();
//
//    Future.delayed(Duration(seconds: 3), () {
//      if (Provider.of<LoginUserInfo>(context).loginInfo == null) {
//        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
//      } else {
//        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PathPage()), (_) => false);
//      }
//    });
//  }
//
//  setStatusBar() async {
//    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
//    await SystemChrome.restoreSystemUIOverlays();
//    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle.dark.copyWith(
//      statusBarColor: Colors.transparent,
//      statusBarBrightness: Platform.isIOS ? Brightness.light : Brightness.dark,
//      systemNavigationBarColor: Colors.black,
//    ); // 此处必须这是为黑色，防止vivo x21刘海屏在横屏时刘海是白色
//    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
//    await SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Theme(
//      data: ThemeData(
//        accentColor: Colors.white,
//        scaffoldBackgroundColor: Colors.white,
//      ),
//      child: Scaffold(
//        body: Container(
//          alignment: Alignment.bottomCenter,
////        child: Stack(
////          children: <Widget>[
////            buildSplashView(),
////            buildContexView(),
////          ],
////        ),
//          child: Column(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              Image(
//                height: 80.0,
//                image: AssetImage('assets/ai_package/images/launcher.webp'),
//                fit: BoxFit.fitHeight,
//              ),
//              SizedBox(
//                height: 13,
//              ),
//              Text(
//                '新东方AI课',
//                style: CustomTextStyle.fz().copyWith(
//                  fontSize: 20.0,
//                  color: const Color(0xFF333333),
//                ),
//              ),
//              SizedBox(
//                height: 70,
//              ),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//
////  Widget buildContexView() {
//////    print("----window 正常加载 MediaQuery222 ${MediaQuery.of(context).size.width}");
////    return Container(
////      alignment: Alignment.center,
////      child: Column(
////        mainAxisAlignment: MainAxisAlignment.center,
////        children: <Widget>[
////          Image.asset(
////            PathImg.pathLogo,
////            width: px(100),
////            height: px(100),
////          ),
////          Padding(
////            padding: EdgeInsets.only(top: 0),
////            child: Text('新东方AI课', style: TextStyle(fontSize: 20, color: Color(0xFF666666))),
////          ),
////        ],
////      ),
////    );
////  }
//
////  Widget buildSplashView() {
////    return Container(
////      width: px(100),
////      height: px(100),
////      child: SplashScreen.navigate(
////        name: 'assets/flares/intro.flr',
////        next: getNext(),
////        until: () => Future.delayed(Duration(seconds: 0)),
////        startAnimation: '1',
////        endAnimation: '0',
////      ),
////    );
////  }
////
////  getNext() {
//////    if (Provider.of<LoginUserInfo>(context).loginInfo == null) {
////    return LoginPage();
//////    } else {
//////      return PathPage();
//////    }
////  }
//}
