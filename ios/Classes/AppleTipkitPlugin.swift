import Flutter
import UIKit
import SwiftUI
import TipKit

public class AppleTipkitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "apple_tipkit", binaryMessenger: registrar.messenger())
    let instance = AppleTipkitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 17.0, *) else {
      result(FlutterError(code: "unavailable", message: "TipKit is available on iOS 17+ only", details: nil))
      return
    }

    switch call.method {
    case "initializeTips":
      do {
        try Tips.configure()
        result(nil)
      } catch {
        result(FlutterError(code: "initialize_error", message: "Failed to configure TipKit", details: error.localizedDescription))
      }

    case "displayTip":
      guard let args = call.arguments as? [String: Any], let tipId = args["tipId"] as? String else {
        result(FlutterError(code: "bad_args", message: "Expected tipId", details: nil))
        return
      }
      let title = args["title"] as? String
      let message = args["message"] as? String
      displayTipById(tipId: tipId, title: title, message: message, result: result)

    case "displayTipAt":
      guard let args = call.arguments as? [String: Any], let tipId = args["tipId"] as? String else {
        result(FlutterError(code: "bad_args", message: "Expected tipId", details: nil))
        return
      }
      let x = args["x"] as? Double
      let y = args["y"] as? Double
      let arrow = (args["arrow"] as? String) ?? "any"
      let title = args["title"] as? String
      let message = args["message"] as? String
      displayTipByIdAt(tipId: tipId, x: x, y: y, arrow: arrow, title: title, message: message, result: result)

    case "displayTipAtRect":
      guard let args = call.arguments as? [String: Any], let tipId = args["tipId"] as? String else {
        result(FlutterError(code: "bad_args", message: "Expected tipId", details: nil))
        return
      }
      guard let left = args["left"] as? Double,
            let top = args["top"] as? Double,
            let width = args["width"] as? Double,
            let height = args["height"] as? Double else {
        result(FlutterError(code: "bad_args", message: "Expected rect left/top/width/height", details: nil))
        return
      }
      let arrow = (args["arrow"] as? String) ?? "any"
      let title = args["title"] as? String
      let message = args["message"] as? String
      displayTipByIdAtRect(tipId: tipId, rect: CGRect(x: left, y: top, width: width, height: height), arrow: arrow, title: title, message: message, result: result)

    case "markTipAsShown":
      guard let args = call.arguments as? [String: Any], let tipId = args["tipId"] as? String else {
        result(FlutterError(code: "bad_args", message: "Expected tipId", details: nil))
        return
      }
      markTipAsShown(tipId: tipId, result: result)

    case "resetAllTips":
      do {
        try Tips.resetDatastore()
        result(nil)
      } catch {
        result(FlutterError(code: "reset_error", message: "Failed to reset TipKit datastore", details: error.localizedDescription))
      }

    case "closeTip":
      dismissPresentedTip(result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

@available(iOS 17.0, *)
fileprivate func displayTipById(tipId: String, title: String?, message: String?, result: @escaping FlutterResult) {
  // Build a basic Tip and present it via TipKit
  let anyTip = SimpleTipRegistry.tip(for: tipId, title: title, message: message)
  guard let anyTip else {
    result(FlutterError(code: "not_found", message: "Tip with id=\(tipId) not registered", details: nil))
    return
  }

  guard let topVC = UIApplication.shared.topViewController() else {
    result(FlutterError(code: "no_vc", message: "Active view controller not found", details: nil))
    return
  }
  
  // Anchor to a predictable point (top-center inside safe area)
  let container = topVC.view!
  let safeFrame = container.safeAreaLayoutGuide.layoutFrame
  let px = safeFrame.midX
  let py = safeFrame.minY + 48
  let anchorView = UIView(frame: CGRect(x: px - 0.5, y: py - 0.5, width: 1, height: 1))
  anchorView.backgroundColor = .clear
  anchorView.isUserInteractionEnabled = false
  container.addSubview(anchorView)

  // Use native TipKit popover controller
  let popover = TipUIPopoverViewController(anyTip, sourceItem: anchorView)
  if let pc = popover.popoverPresentationController {
    pc.sourceView = container
    pc.sourceRect = CGRect(x: px, y: py, width: 1, height: 1)
    pc.permittedArrowDirections = .up
  }
  _currentTipController = popover
  DispatchQueue.main.async {
    topVC.present(popover, animated: true) {
      result(nil)
    }
  }
}

@available(iOS 17.0, *)
fileprivate func displayTipByIdAt(
  tipId: String,
  x: Double?,
  y: Double?,
  arrow: String,
  title: String?,
  message: String?,
  result: @escaping FlutterResult
) {
  // Build a basic Tip and present it anchored to a normalized point within the safe area.
  guard let anyTip = SimpleTipRegistry.tip(for: tipId, title: title, message: message) else {
    result(FlutterError(code: "not_found", message: "Tip with id=\(tipId) not registered", details: nil))
    return
  }
  guard let topVC = UIApplication.shared.topViewController() else {
    result(FlutterError(code: "no_vc", message: "Active view controller not found", details: nil))
    return
  }

  let container = topVC.view!
  let safeFrame = container.safeAreaLayoutGuide.layoutFrame
  let nx: CGFloat = x != nil ? CGFloat(max(0.0, min(1.0, x!))) : 0.5
  let ny: CGFloat = y != nil ? CGFloat(max(0.0, min(1.0, y!))) : 0.5
  let px = safeFrame.minX + nx * safeFrame.width
  let py = safeFrame.minY + ny * safeFrame.height

  // Invisible 1x1 anchor view at target point
  let anchorView = UIView(frame: CGRect(x: px - 0.5, y: py - 0.5, width: 1, height: 1))
  anchorView.backgroundColor = .clear
  anchorView.isUserInteractionEnabled = false
  container.addSubview(anchorView)

  // Use native TipKit popover controller anchored to the view
  let popover = TipUIPopoverViewController(anyTip, sourceItem: anchorView)
  if let pc = popover.popoverPresentationController {
    pc.sourceView = container
    pc.sourceRect = CGRect(x: px, y: py, width: 1, height: 1)
    pc.permittedArrowDirections = mapArrowDirections(arrow)
  }
  _currentTipController = popover
  DispatchQueue.main.async {
    topVC.present(popover, animated: true) {
      result(nil)
    }
  }
}

@available(iOS 17.0, *)
fileprivate func displayTipByIdAtRect(
  tipId: String,
  rect: CGRect,
  arrow: String,
  title: String?,
  message: String?,
  result: @escaping FlutterResult
) {
  guard let anyTip = SimpleTipRegistry.tip(for: tipId, title: title, message: message) else {
    result(FlutterError(code: "not_found", message: "Tip with id=\(tipId) not registered", details: nil))
    return
  }
  guard let topVC = UIApplication.shared.topViewController() else {
    result(FlutterError(code: "no_vc", message: "Active view controller not found", details: nil))
    return
  }
  let container = topVC.view!
  let anchorView = UIView(frame: rect)
  anchorView.backgroundColor = .clear
  anchorView.isUserInteractionEnabled = false
  container.addSubview(anchorView)

  let popover = TipUIPopoverViewController(anyTip, sourceItem: anchorView)
  if let pc = popover.popoverPresentationController {
    pc.sourceView = container
    pc.sourceRect = rect
    pc.permittedArrowDirections = mapArrowDirections(arrow)
  }
  _currentTipController = popover
  DispatchQueue.main.async {
    topVC.present(popover, animated: true) {
      result(nil)
    }
  }
}

@available(iOS 17.0, *)
fileprivate func mapArrowDirections(_ value: String) -> UIPopoverArrowDirection {
  switch value.lowercased() {
  case "up": return .up
  case "down": return .down
  case "left": return .left
  case "right": return .right
  default: return .any
  }
}

@available(iOS 17.0, *)
fileprivate func markTipAsShown(tipId: String, result: @escaping FlutterResult) {
  let tip = SimpleTipRegistry.tip(for: tipId, title: nil, message: nil)
  guard let tip else {
    result(FlutterError(code: "not_found", message: "Tip with id=\(tipId) not registered", details: nil))
    return
  }
  tip.invalidate(reason: .actionPerformed)
  result(nil)
}

@available(iOS 17.0, *)
fileprivate func dismissPresentedTip(result: @escaping FlutterResult) {
  // Dismiss top-most presented tip popover if any.
  guard let topVC = UIApplication.shared.topViewController() else {
    result(FlutterError(code: "no_vc", message: "Active view controller not found", details: nil))
    return
  }
  if let c = _currentTipController ?? topVC.presentedViewController {
    c.dismiss(animated: true) {
      result(nil)
    }
  } else {
    result(FlutterError(code: "no_tip", message: "No presented tip to dismiss", details: nil))
  }
}

@available(iOS 17.0, *)
fileprivate enum SimpleTipRegistry {
  // Minimal Tip identified by id for datastore operations and demo presentation.
  struct BasicTip: Tip {
    let id: String
    let customTitle: String?
    let customMessage: String?
    var title: Text { Text(customTitle ?? "Tip: \(id)") }
    var message: Text? { Text(customMessage ?? "This is a helpful tip about \(id). Tap to dismiss.") }
    var options: [Option] { [IgnoresDisplayFrequency(true), MaxDisplayCount(100)] }
  }

  static func tip(for id: String, title: String?, message: String?) -> AnyTip? {
    // The plugin does not know app-specific Tip types.
    // Provide a universal BasicTip to operate on TipKit datastore and for demo display.
    let tip = BasicTip(id: id, customTitle: title, customMessage: message)
    return AnyTip(tip)
  }
}

extension UIApplication {
  fileprivate func topViewController(base: UIViewController? = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
      return topViewController(base: selected)
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }

  fileprivate var keyWindowInConnectedScenes: UIWindow? {
    return self.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }
}

// Keep a weak reference to the currently presented tip controller to ensure proper dismissal
@available(iOS 17.0, *)
fileprivate weak var _currentTipController: UIViewController?


