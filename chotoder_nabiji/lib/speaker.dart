import 'package:flutter_tts/flutter_tts.dart';

/// Reads Bengali text aloud with the device's text-to-speech engine so that
/// children who cannot read yet can listen. Recorded human narration can
/// replace this later without changing the screens.
class Speaker {
  Speaker._();
  static final Speaker instance = Speaker._();

  FlutterTts? _tts;
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    try {
      final tts = FlutterTts();
      await tts.setLanguage('bn-BD');
      await tts.setSpeechRate(0.42);
      await tts.setPitch(1.05);
      _tts = tts;
    } catch (_) {
      _tts = null;
    }
    _ready = true;
  }

  /// Text-to-speech cannot read the ﷺ ligature, so spell it out.
  static String prepare(String text) => text
      .replaceAll('ﷺ', ' সাল্লাল্লাহু আলাইহি ওয়াসাল্লাম ')
      .replaceAll('(রা.)', ' রাদিয়াল্লাহু আনহু ')
      .replaceAll('(আ.)', ' আলাইহিস সালাম ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Future<void> speak(String text) async {
    await _init();
    try {
      await _tts?.stop();
      await _tts?.speak(prepare(text));
    } catch (_) {/* no voice available on this device */}
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
