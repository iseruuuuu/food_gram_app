import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 通知の設定
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // Firebase Messagingの設定
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    // APNsトークンの登録
    application.registerForRemoteNotifications()

    // アプリ起動時にバッジをクリア
    application.applicationIconBadgeNumber = 0

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // APNsトークンの登録成功時の処理
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Firebase MessagingにAPNsトークンを設定
    Messaging.messaging().apnsToken = deviceToken
  }

  // APNsトークンの登録失敗時の処理
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("APNsトークンの登録に失敗しました: \(error.localizedDescription)")
  }

  // 通知を受信したときの処理（バックグラウンドでも動作）
  override func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // Firebase Messagingに通知を渡す
    Messaging.messaging().appDidReceiveMessage(userInfo)
    completionHandler(.newData)
  }

  // ディープリンク処理: アプリがURLで開かれたとき
  override func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    // FlutterAppDelegateが自動的に処理する
    return super.application(app, open: url, options: options)
  }

  // ディープリンク処理: アプリがバックグラウンドでURLで開かれたとき
  override func application(_ application: UIApplication,
                            continue userActivity: NSUserActivity,
                            restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    // FlutterAppDelegateが自動的に処理する
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
