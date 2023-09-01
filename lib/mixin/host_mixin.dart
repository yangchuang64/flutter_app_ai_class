
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';

/// 设置请求地址
void setHostUrl([HostEnv env, bool isForce = false]) {
  if (isForce) {
    // 可以在测试环境强制设置url，只针对测试环境
    _setTestHost(env);
  } else {
    // 如果不需要强制设置，就走默认的设置
    if (env != null) {
      _setTestHost(env);
    } else {
      setProductionHost();
    }
  }
}


/// 设置测试环境url
void _setTestHost(HostEnv env) {
  switch (env) {
    case HostEnv.prod:
      setProductionHost();
      break;
    case HostEnv.t:
      setDevHost('');
      break;
    case HostEnv.alpha:
      setDevHost('-alpha');
      break;
    case HostEnv.smix1:
      setDevHost('-smix1');
      break;
    case HostEnv.smix2:
      setDevHost('-smix2');
      break;
    case HostEnv.smix3:
      setDevHost('-smix3');
      break;
    case HostEnv.smix4:
      setDevHost('-smix4');
      break;
    case HostEnv.smix5:
      setDevHost('-smix5');
      break;
    case HostEnv.smix6:

      /// todo ... six6 配追的是beta环境
      setDevHost('-beta');
      break;
    case HostEnv.gamma:
      setDevHost('-gamma');
      break;
  }
}

enum HostEnv {
  prod,
  t,
  alpha,
  smix1,
  smix2,
  smix3,
  smix4,
  smix5,
  smix6,
  gamma,
}
