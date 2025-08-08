import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:apple_tipkit/apple_tipkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'apple_tipkit example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _log = '';
  final GlobalKey _showButtonKey = GlobalKey();

  Future<void> _init() async {
    try {
      await AppleTipkit.initializeTips();
      setState(() => _log = 'TipKit initialized');
    } catch (e) {
      setState(() => _log = 'Error: $e');
    }
  }

  Future<void> _show() async {
    try {
      final ctx = _showButtonKey.currentContext;
      if (ctx == null) {
        setState(() => _log = 'Error: button context is null');
        return;
      }
      final render = ctx.findRenderObject() as RenderBox;
      final offset = render.localToGlobal(Offset.zero);
      final size = render.size;

      // Prefer absolute rect anchoring for precision
      final rectLeft = offset.dx;
      final rectTop = offset.dy;
      final rectWidth = size.width;
      final rectHeight = size.height;

      debugPrint(
          'Button rect (pts): L=${rectLeft.toStringAsFixed(1)} T=${rectTop.toStringAsFixed(1)} W=${rectWidth.toStringAsFixed(1)} H=${rectHeight.toStringAsFixed(1)}');

      await AppleTipkit.displayTipAtRect(
        'example_tip',
        left: rectLeft,
        top: rectTop,
        width: rectWidth,
        height: rectHeight,
        arrow: 'down',
        title: "This is title",
        message: "This is message",
      );
      setState(() => _log = 'Displayed tip example_tip');
    } catch (e) {
      setState(() => _log = 'Error: $e');
    }
  }

  Future<void> _reset() async {
    try {
      await AppleTipkit.resetAllTips();
      setState(() => _log = 'All tips reset');
    } catch (e) {
      setState(() => _log = 'Error: $e');
    }
  }

  Future<void> _close() async {
    try {
      await AppleTipkit.closeTip();
      setState(() => _log = 'Closed tip if presented');
    } catch (e) {
      setState(() => _log = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('apple_tipkit example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                onPressed: _init, child: const Text('Initialize TipKit')),
            const SizedBox(height: 12),
            ElevatedButton(
                key: _showButtonKey,
                onPressed: _show,
                child: const Text('Display Tip')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _close, child: const Text('Close Tip')),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _reset, child: const Text('Reset All Tips')),
            const SizedBox(height: 24),
            Text(_log),
          ],
        ),
      ),
    );
  }
}
