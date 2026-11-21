import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ShamailScreen extends StatefulWidget {
  const ShamailScreen({super.key});

  @override
  State<ShamailScreen> createState() => _ShamailScreenState();
}

class _ShamailScreenState extends State<ShamailScreen> {
  final _controller = PageController(viewportFraction: 0.9);
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final cards = AppScope.of(context).content.shamail;
    return Scaffold(
      appBar: AppBar(title: const Text('নবীজী ﷺ কেমন ছিলেন')),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'সাহাবিরা নিজের চোখে নবীজী ﷺ-কে যেমন দেখেছেন, তেমনই বলেছেন। '
                'আমরা তাঁর ছবি আঁকি না, কিন্তু তাঁদের কথা শুনে মনের চোখে তাঁকে ভালোবাসি।',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: cards.length,
                onPageChanged: (p) => setState(() => _page = p),
                itemBuilder: (_, i) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: _ShamailCardView(card: cards[i]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('${bn(_page + 1)} / ${bn(cards.length)}',
                  style: const TextStyle(color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShamailCardView extends StatelessWidget {
  const _ShamailCardView({required this.card});
  final ShamailCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
              color: AppColors.green.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: SingleChildScrollView(
        child: Column(
          children: [
            EmojiBadge(card.emoji,
                size: 96, background: AppColors.green.withValues(alpha: 0.1)),
            const SizedBox(height: 18),
            Text(card.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenDark)),
            const SizedBox(height: 14),
            Text(card.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, height: 1.7)),
            const SizedBox(height: 12),
            SpeakButton(text: '${card.title}। ${card.text}'),
            SourceNote(card.source),
          ],
        ),
      ),
    );
  }
}
