import 'package:bling_downloader/bling_downloader.dart';
import 'package:flame/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_ai_math/mixin/GameList.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/routers/routers.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/student_class_vo.dart';
import 'package:flutterblingaiplugin/screen/configs/theme_data.dart';
import 'package:flutterblingaiplugin/screen/uitils/local_data.dart';
import 'package:flutterblingaiplugin/screen/uitils/log.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/net_connect.dart';
import 'package:flutterblingaiplugin/screen/uitils/shared_preferences.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/uitils/umeng_action_count.dart';
import 'package:protect_eye/protect_eye.dart';
import 'package:provider/provider.dart';

/// 启动应用
startApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  Util flameUtil = Util();
  flameUtil.fullScreen();
  flameUtil.setOrientation(DeviceOrientation.landscapeLeft);

  /// 路由注册表注册
  RouterManager.configureRoutes();

  /// 友盟统计初始化
  UmengCounter.init();

  /// 本地化储存
  await local_data_init();

  /// 启动网络状态监测
  NetConnect.startNetConnectivityMonitor();

  /// 检测护眼模式是否开启
  SpUtil.getInstance().then((spl) {
    ProtectEye.setProtectModel(spl.getBool("protectModel") ?? false);
  });

  /// 超过七天的数据缓存清理掉
  Future.delayed(Duration(seconds: 5), () {
    BlingDownloader.clearCache(day: 7);
  });

  imageCache.maximumSize = 10;
  imageCache.maximumSizeBytes = 10;

  /// LoginUserInfo.getInstance 初始化用户模型数据导入根状态管理器
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginUserInfo>(create: (_) => LoginUserInfo.getInstance(null)),
        ChangeNotifierProvider<AppTheme>(create: (_) => AppTheme.instance),
        ChangeNotifierProvider<ValueNotifier<AiStudentClassVO>>(create: (_) => ValueNotifier<AiStudentClassVO>(null)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (inProduction == true) {
      ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
        return ExceptionWidget(errorDetails);
      };
    }
    return MaterialApp(
      navigatorKey: LoginUserInfo.navigatorKey,
      title: '比邻AI数学',
      theme: AppTheme.instance.currentTheme,
      onGenerateRoute: RouterManager.router.generator,
      home: homePage(context),
      navigatorObservers: [routeObserver],
    );
  }

  Widget homePage(BuildContext context) {
    LoginInfo loginInfo = Provider.of<LoginUserInfo>(context, listen: false).loginInfo;
    printLog("登录用户信息tokent", "${loginInfo?.token}");
    // if (loginInfo == null) {
    //   return LoginPage();
    // } else {
    //   return PathPage();
    // }
    return GameListPage();
  }
}

class ExceptionWidget extends StatelessWidget {
  final FlutterErrorDetails error;

  ExceptionWidget(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onDoubleTap: () => Navigator.of(context).pop(),
          child: Text("<双击退出>发生错误了<双击退出>\n${error.toString()}"),
        ),
      ),
    );
  }
}
