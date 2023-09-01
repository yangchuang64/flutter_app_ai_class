import 'package:fluro/fluro.dart';

import 'router_config.dart';

export 'router_config.dart';

///
/// Rout控制器，跳转方式设置
///
class RouterManager {
  static Router router = Router();

  static void configureRoutes() {
    routerMap.forEach((path, handler) {
      TransitionType transitionType = TransitionType.inFromRight;
      // todo ... 跳转方式配置
      if (path == PagePath.aiDetail) transitionType = TransitionType.fadeIn;
      if (path == PagePath.aiFinish) transitionType = TransitionType.inFromRight;
      router.define(path, handler: handler, transitionType: transitionType);
    });
  }
}
