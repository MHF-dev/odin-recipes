import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SunnahGardenScreen extends StatelessWidget {
  const SunnahGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final list = state.content.sunnah;
    final today = state.sunnahToday;
    return Scaffold(
      appBar: AppBar(title: const Text('আমার সুন্নাহ বাগান')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Garden(sunnah: list, done: today),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('আজ ${bn(today.length)}টি ফুল ফুটেছে',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  if (state.sunnahStreak > 1) ...[
                    const SizedBox(width: 10),
                    Text('🔥 টানা ${bn(state.sunnahStreak)} দিন',
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFFE65100))),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'আজ যে সুন্নাহগুলো পালন করেছ, সেগুলোতে চাপ দাও। প্রতিটি সুন্নাহয় বাগানে একটি ফুল ফুটবে!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
              const SizedBox(height: 14),
              for (final s in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SunnahTile(
                    sunnah: s,
                    done: today.contains(s.id),
                    onTap: () => state.toggleSunnah(s.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Garden extends StatelessWidget {
  const _Garden({required this.sunnah, required this.done});
  final List<Sunnah> sunnah;
  final Set<String> done;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD9F0FF), Color(0xFFF2FBF4)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
              top: 12, right: 20, child: Text('☀️', style: TextStyle(fontSize: 34))),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF8BC34A),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 22,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              children: [
                for (final s in sunnah)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (c, a) =>
                        ScaleTransition(scale: a, child: c),
                    child: Text(
                      done.contains(s.id) ? s.flower : '🌱',
                      key: ValueKey('${s.id}${done.contains(s.id)}'),
                      style: TextStyle(
                          fontSize: done.contains(s.id) ? 34 : 20),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SunnahTile extends StatelessWidget {
  const _SunnahTile(
      {required this.sunnah, required this.done, required this.onTap});
  final Sunnah sunnah;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: done ? const Color(0xFFE8F5E9) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: Key('sunnah_${sunnah.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: done ? AppColors.green : AppColors.sandDeep, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sunnah.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sunnah.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(sunnah.hadith,
                        style: const TextStyle(fontSize: 15, height: 1.5)),
                    SourceNote(sunnah.source),
                  ],
                ),
              ),
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done ? AppColors.green : AppColors.muted,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
