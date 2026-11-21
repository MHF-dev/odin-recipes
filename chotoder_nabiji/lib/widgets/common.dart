import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../speaker.dart';
import '../theme.dart';

/// Round "listen" button shown next to every piece of text.
class SpeakButton extends StatelessWidget {
  const SpeakButton({super.key, required this.text, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.ttsEnabled) return const SizedBox.shrink();
    return IconButton.filledTonal(
      tooltip: 'শুনুন',
      iconSize: 26,
      onPressed: () => Speaker.instance.speak(text),
      icon: Icon(Icons.volume_up_rounded, color: color ?? AppColors.green),
    );
  }
}

/// Small grey reference line under every piece of content.
class SourceNote extends StatelessWidget {
  const SourceNote(this.source, {super.key});
  final String source;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.menu_book_rounded,
                size: 16, color: AppColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'সূত্র: $source',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
}

/// Shows a simple arithmetic question so that only grown-ups can open the
/// parent area (required by Google Play's Families policy).
Future<bool> showParentGate(BuildContext context) async {
  final rnd = Random();
  final a = 6 + rnd.nextInt(9);
  final b = 3 + rnd.nextInt(7);
  final controller = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('অভিভাবকদের জন্য'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$a × $b = কত?', style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 12),
          TextField(
            key: const Key('parentGateField'),
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'উত্তর লিখুন (ইংরেজি সংখ্যায়)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('বাতিল')),
        FilledButton(
          onPressed: () => Navigator.pop(
              ctx, int.tryParse(toLatinDigits(controller.text.trim())) == a * b),
          child: const Text('প্রবেশ'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

const _bnDigits = '০১২৩৪৫৬৭৮৯';

/// Converts Latin digits to Bengali digits for display.
String bn(Object n) => n
    .toString()
    .split('')
    .map((c) {
      final d = int.tryParse(c);
      return d == null ? c : _bnDigits[d];
    })
    .join();

String toLatinDigits(String s) => s.split('').map((c) {
      final i = _bnDigits.indexOf(c);
      return i < 0 ? c : '$i';
    }).join();

/// Colourful rounded header used on the home grid and story covers.
class EmojiBadge extends StatelessWidget {
  const EmojiBadge(this.emoji,
      {super.key, this.size = 56, this.background = AppColors.sandDeep});
  final String emoji;
  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
      );
}
