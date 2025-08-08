### apple_tipkit

Flutter-плагин (iOS 17+) — обёртка над Apple TipKit.

- Ядро iOS: Swift + `import TipKit`
- Метод-канал: `apple_tipkit`
- Методы:
  - `initializeTips()`
  - `displayTip(String tipId, {String? title, String? message})`
  - `displayTipAt(String tipId, {double? x, double? y, String arrow = 'any', String? title, String? message})`
  - `displayTipAtRect(String tipId, {required double left, required double top, required double width, required double height, String arrow = 'any', String? title, String? message})`
  - `markTipAsShown(String tipId)`
  - `resetAllTips()`
  - `closeTip()`

### Установка

Добавьте в `pubspec.yaml` вашего приложения:

```yaml
dependencies:
  apple_tipkit: ^0.1.0
```

Минимальная iOS: 17.0.

### Использование

```dart
import 'package:apple_tipkit/apple_tipkit.dart';

await AppleTipkit.initializeTips();
// Default placement with custom title/message
await AppleTipkit.displayTip('welcome_tip', title: 'Welcome', message: 'Tap to continue');

// Anchored placement (normalized coords inside safe area)
await AppleTipkit.displayTipAt('welcome_tip', x: 0.9, y: 0.15, arrow: 'down', title: 'Menu', message: 'Open options');

// Absolute rect (points in main window space)
await AppleTipkit.displayTipAtRect('welcome_tip', left: 24, top: 88, width: 32, height: 32, arrow: 'right');
await AppleTipkit.markTipAsShown('welcome_tip');
await AppleTipkit.resetAllTips();
await AppleTipkit.closeTip();
```

- На не‑iOS платформах методы бросают `UnimplementedError`.
- `displayTip` показывает системный TipKit-поповер с базовым содержимым.

### Ограничения

TipKit не предоставляет глобального реестра по строковому `id`. Плагин создаёт простой `Tip` по `tipId` для управления datastore и тестового показа. Для продакшна рекомендуется собственная Tip-модель и размещение вью через SwiftUI/TipKit.

### Лицензия

MIT


