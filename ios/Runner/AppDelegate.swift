import UIKit
import Flutter
import push

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    PushPlugin.initAppID(1600008271, appKey: "I1TTZSNSH2CT")
    /// 屏幕常亮
    application.isIdleTimerDisabled = true
    UIApplication.shared.isIdleTimerDisabled = true
    GeneratedPluginRegistrant.register(with: self)
//    UIApplication.shared.cancelAllLocalNotifications();
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
