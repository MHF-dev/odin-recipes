import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'dua_screen.dart';
import 'family_screen.dart';
import 'love_screen.dart';
import 'parent_screen.dart';
import 'shamail_screen.dart';
import 'stories_screen.dart';
import 'sunnah_garden_screen.dart';

class _Module {
  final String emoji, title, subtitle;
  final Color color;
  final Widget Function() page;
  const _Module(this.emoji, this.title, this.subtitle, this.color, this.page);
}

final _modules = <_Module>[
  _Module('📖', 'নবীজীর গল্প', 'জন্ম থেকে বিদায়', const Color(0xFF1F7A55),
      () => const StoriesScreen()),
  _Module('💚', 'নবীজী কেমন ছিলেন', 'চেহারা ও চরিত্র', const Color(0xFF2E7D32),
      () => const ShamailScreen()),
  _Module('🌱', 'সুন্নাহ বাগান', 'আজকের সুন্নাহ', const Color(0xFF558B2F),
      () => const SunnahGardenScreen()),
  _Module('🤲', 'দরুদ ও দোয়া', 'শিখি ও পড়ি', const Color(0xFF00796B),
      () => const DuaScreen()),
  _Module('🌳', 'নবীজীর পরিবার', 'আপনজনদের চিনি', const Color(0xFF8D6E63),
      () => const FamilyScreen()),
  _Module('✉️', 'ভালোবাসার চিঠি', 'নবীজীকে লিখি', const Color(0xFFC2185B),
      () => const LoveScreen()),
];

const _dailyHadith = [
  'নবীজী ﷺ বলেছেন, "তোমাদের মধ্যে সর্বোত্তম সে, যার চরিত্র সবচেয়ে সুন্দর।" (বুখারী ৬০৩৫)',
  'নবীজী ﷺ বলেছেন, "যে আমার ওপর একবার দরুদ পড়ে, আল্লাহ তার ওপর দশবার রহমত বর্ষণ করেন।" (মুসলিম ৪০৮)',
  'নবীজী ﷺ বলেছেন, "তোমার ভাইয়ের সামনে হাসিমুখে থাকাও সাদাকা।" (তিরমিযী ১৯৫৬)',
  'নবীজী ﷺ বলেছেন, "মানুষ তার সাথেই থাকবে, যাকে সে ভালোবাসে।" (বুখারী ৬১৬৮)',
  'নবীজী ﷺ বলেছেন, "যে মানুষের প্রতি দয়া করে না, আল্লাহ তার প্রতি দয়া করেন না।" (বুখারী ৭৩৭৬)',
  'নবীজী ﷺ বলেছেন, "তোমরা নিজেদের মধ্যে সালামের প্রসার ঘটাও।" (মুসলিম ৫৪)',
  'নবীজী ﷺ বলেছেন, "তোমাদের কেউ মুমিন হবে না, যতক্ষণ না আমি তার কাছে তার পিতা, সন্তান ও সব মানুষের চেয়ে প্রিয় হই।" (বুখারী ১৫)',
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hadith = _dailyHadith[DateTime.now().day % _dailyHadith.length];
    final greeting = state.childName.isEmpty
        ? 'আসসালামু আলাইকুম!'
        : 'আসসালামু আলাইকুম, ${state.childName}!';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ছোটদের নবীজী ﷺ'),
        actions: [
          IconButton(
            key: const Key('parentButton'),
            tooltip: 'অভিভাবক কর্নার',
            icon: const Icon(Icons.family_restroom_rounded),
            onPressed: () async {
              if (await showParentGate(context) && context.mounted) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ParentScreen()));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Text(greeting,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _StatsRow(state: state),
                const SizedBox(height: 14),
                _HadithCard(text: hadith),
                const SizedBox(height: 18),
                LayoutBuilder(builder: (context, c) {
                  final cols = c.maxWidth > 560 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: [for (final m in _modules) _ModuleTile(m)],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    Widget stat(String emoji, String value, String label) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sandDeep),
            ),
            child: Column(
              children: [
                Text('$emoji ${bn(value)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                Text(label,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
        );
    return Row(
      children: [
        stat('⭐', '${state.stars}', 'তারা'),
        const SizedBox(width: 8),
        stat('📖', '${state.completedStories.length}', 'গল্প পড়া'),
        const SizedBox(width: 8),
        stat('🌸', '${state.totalFlowers}', 'সুন্নাহ ফুল'),
      ],
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.green, AppColors.greenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌙 আজকের হাদিস',
                    style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 6),
                Text(text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 17, height: 1.5)),
              ],
            ),
          ),
          SpeakButton(text: text),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile(this.m);
  final _Module m;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => m.page())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: m.color.withValues(alpha: 0.25), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmojiBadge(m.emoji,
                  size: 64, background: m.color.withValues(alpha: 0.12)),
              const SizedBox(height: 10),
              Text(m.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: m.color)),
              Text(m.subtitle,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
