import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Firebase آمن: لا ينهار إذا ملف GoogleService-Info.plist موجود
    if let _ = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
      FirebaseApp.configure()
    }

    GeneratedPluginRegistrant.register(with: self)

    // إصلاح مشاكل WebView/وسائط بالخلفية
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    UIApplication.shared.isIdleTimerDisabled = true

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
