import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// Thin Dart facade for the native TipKit bridge (iOS 17+ only).
class AppleTipkit {
  static const MethodChannel _channel = MethodChannel('apple_tipkit');

  /// Configure TipKit datastore and eligibility.
  static Future<void> initializeTips() async {
    _ensureIOS();
    await _channel.invokeMethod('initializeTips');
  }

  /// Present a tip popover identified by [tipId].
  /// Optional [title] and [message] override default content.
  static Future<void> displayTip(String tipId,
      {String? title, String? message}) async {
    _ensureIOS();
    await _channel.invokeMethod('displayTip', {
      'tipId': tipId,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
    });
  }

  /// Present a tip popover at a specific anchor within the screen.
  ///
  /// [x] and [y] are normalized coordinates in range [0, 1] relative to the
  /// visible view bounds (after safe area insets). If null, the center is used.
  /// [arrow] can be one of: 'up', 'down', 'left', 'right', 'any'. Defaults to 'any'.
  static Future<void> displayTipAt(
    String tipId, {
    double? x,
    double? y,
    String arrow = 'any',
    String? title,
    String? message,
  }) async {
    _ensureIOS();
    await _channel.invokeMethod('displayTipAt', {
      'tipId': tipId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      'arrow': arrow,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
    });
  }

  /// Present a tip popover anchored to an absolute rectangle in screen points.
  /// Rect coordinates are expected in the main window coordinate space (logical points).
  static Future<void> displayTipAtRect(
    String tipId, {
    required double left,
    required double top,
    required double width,
    required double height,
    String arrow = 'any',
    String? title,
    String? message,
  }) async {
    _ensureIOS();
    await _channel.invokeMethod('displayTipAtRect', {
      'tipId': tipId,
      'left': left,
      'top': top,
      'width': width,
      'height': height,
      'arrow': arrow,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
    });
  }

  /// Mark tip identified by [tipId] as shown (invalidate with actionPerformed).
  static Future<void> markTipAsShown(String tipId) async {
    _ensureIOS();
    await _channel.invokeMethod('markTipAsShown', {'tipId': tipId});
  }

  /// Reset all tips datastore.
  static Future<void> resetAllTips() async {
    _ensureIOS();
    await _channel.invokeMethod('resetAllTips');
  }

  /// Dismiss currently presented tip popover (if any).
  static Future<void> closeTip() async {
    _ensureIOS();
    await _channel.invokeMethod('closeTip');
  }

  static void _ensureIOS() {
    if (!Platform.isIOS) {
      throw UnimplementedError('apple_tipkit supports iOS 17+ only');
    }
  }
}
