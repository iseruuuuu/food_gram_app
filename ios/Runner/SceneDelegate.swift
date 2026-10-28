import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private let calendarDayAppGroup = "group.com.FoodGram.ios"
  private let calendarDayLaunchKey = "calendar_day_launch"

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    for context in connectionOptions.urlContexts {
      storeCalendarDay(from: context.url)
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    for context in URLContexts {
      storeCalendarDay(from: context.url)
    }
    super.scene(scene, openURLContexts: URLContexts)
  }

  /// ウィジェットの日付 URL を、Flutter が読む App Group に残す。
  private func storeCalendarDay(from url: URL) {
    guard url.scheme == "com.foodgram.scheme",
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      components.host == "calendar-day",
      let date = components.queryItems?.first(where: { $0.name == "date" })?.value,
      !date.isEmpty
    else {
      return
    }
    let defaults = UserDefaults(suiteName: calendarDayAppGroup)
    defaults?.set(date, forKey: calendarDayLaunchKey)
    defaults?.synchronize()
  }
}
