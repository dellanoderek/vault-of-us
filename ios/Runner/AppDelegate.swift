import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let fileProtectionChannel = FlutterMethodChannel(name: "com.vaultofus.security/file_protection",
                                              binaryMessenger: controller.binaryMessenger)

    fileProtectionChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Aplicação do NSFileProtection exigido no documento
      if call.method == "setFileProtection" {
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String,
              let protectionLevel = args["protectionLevel"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments filePath and protectionLevel are required", details: nil))
          return
        }

        self.setFileProtection(filePath: filePath, protectionLevel: protectionLevel, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    // GeneratedPluginRegistrant.register(with: self) // descomente após rodar flutter create
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setFileProtection(filePath: String, protectionLevel: String, result: FlutterResult) {
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: filePath) {
      result(FlutterError(code: "FILE_NOT_FOUND", message: "File does not exist at path: \(filePath)", details: nil))
      return
    }

    var fileProtectionAttr: FileAttributeValue
    switch protectionLevel {
    case "complete":
      fileProtectionAttr = .complete // NSFileProtectionComplete (Arquivos altamente sensíveis)
    case "completeUntilFirstUserAuthentication":
      fileProtectionAttr = .completeUntilFirstUserAuthentication // NSFileProtectionCompleteUntilFirstUserAuthentication (Arquivos comuns)
    default:
      fileProtectionAttr = .none
    }

    do {
      try fileManager.setAttributes([.protectionKey: fileProtectionAttr], ofItemAtPath: filePath)
      result(true)
    } catch {
      result(FlutterError(code: "SET_ATTRIBUTE_FAILED", message: "Failed to set file protection: \(error.localizedDescription)", details: nil))
    }
  }
}
