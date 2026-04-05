import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // 在引擎創建時註冊 channel（早於 main()），讓 Dart 能從 Info.plist 讀到 token
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "FilmtraceMapbox") else { return }
    let channel = FlutterMethodChannel(
      name: "filmtrace_hk/mapbox",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "getAccessToken" {
        let token = Bundle.main.object(forInfoDictionaryKey: "MGLMapboxAccessToken") as? String ?? ""
        result(token)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
