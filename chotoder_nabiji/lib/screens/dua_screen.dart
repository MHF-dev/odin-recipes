import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final duas = AppScope.of(context).content.duas;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('দরুদ ও দোয়া'),
          bottom: const TabBar(
            labelStyle: TextStyle(
                fontFamily: 'HindSiliguri',
                fontSize: 17,
                fontWeight: FontWeight.w700),
            tabs: [Tab(text: '💚 দরুদ কাউন্টার'), Tab(text: '🤲 দোয়া শিখি')],
          ),
        ),
        body: TabBarView(
          children: [
            const DuroodCounter(),
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: duas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: DuaCard(dua: duas[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DuroodCounter extends StatelessWidget {
  const DuroodCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: arabicStyle),
            const Text('সাল্লাল্লাহু আলাইহি ওয়াসাল্লাম',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            GestureDetector(
              key: const Key('duroodButton'),
              onTap: () => state.addDurood(),
              child: Container(
                width: 210,
                height: 210,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                      colors: [Color(0xFF34A273), AppColors.greenDark]),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(bn(state.duroodToday),
                        key: const Key('duroodToday'),
                        style: const TextStyle(
                            fontSize: 64,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    const Text('আজ',
                        style: TextStyle(color: Colors.white70, fontSize: 18)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('প্রতিবার দরুদ পড়ে বৃত্তে চাপ দাও',
                style: TextStyle(color: AppColors.muted, fontSize: 16)),
            const SizedBox(height: 20),
            Text('এ পর্যন্ত মোট: ${bn(state.duroodTotal)} বার 💚',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.sandDeep),
              ),
              child: const Column(
                children: [
                  Text(
                    'নবীজী ﷺ বলেছেন, "যে আমার ওপর একবার দরুদ পড়ে, আল্লাহ তার ওপর দশবার রহমত বর্ষণ করেন।"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, height: 1.6),
                  ),
                  SourceNote('সহীহ মুসলিম ৪০৮'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DuaCard extends StatelessWidget {
  const DuaCard({super.key, required this.dua});
  final Dua dua;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dua.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      Text('কখন: ${dua.when}',
                          style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
                SpeakButton(text: '${dua.pronunciation}। অর্থ: ${dua.meaning}'),
              ],
            ),
            const SizedBox(height: 10),
            Text(dua.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: arabicStyle),
            const SizedBox(height: 8),
            Text(dua.pronunciation,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                    height: 1.6)),
            const SizedBox(height: 6),
            Text('অর্থ: ${dua.meaning}',
                style: const TextStyle(fontSize: 17, height: 1.6)),
            SourceNote(dua.source),
          ],
        ),
      ),
    );
  }
}
