import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.story});
  final Story story;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int _correct = 0;
  int? _picked;
  late List<QuizQuestion> _questions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final little = AppScope.read(context).ageGroup == AgeGroup.little;
    // Little ones get a gentle quiz with fewer questions.
    _questions = little
        ? widget.story.quiz.take(2).toList()
        : widget.story.quiz;
  }

  void _pick(int i) {
    if (_picked != null) return;
    setState(() {
      _picked = i;
      if (i == _questions[_index].answer) _correct++;
    });
  }

  void _next() {
    if (_index == _questions.length - 1) {
      AppScope.read(context).recordQuiz(widget.story.id, _correct);
    }
    setState(() {
      _index++;
      _picked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    final finished = _index >= _questions.length;
    return Scaffold(
      appBar: AppBar(title: const Text('চলো যাচাই করি')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: finished ? _result(s) : _question(s),
          ),
        ),
      ),
    );
  }

  Widget _question(Story s) {
    final q = _questions[_index];
    return ListView(
      children: [
        LinearProgressIndicator(
          value: (_index + 1) / _questions.length,
          color: s.color,
          backgroundColor: s.lightColor,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 8),
        Text('প্রশ্ন ${bn(_index + 1)} / ${bn(_questions.length)}',
            style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(q.question,
                  style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.w700, height: 1.5)),
            ),
            SpeakButton(
                text: '${q.question} ${q.options.join(', অথবা ')}',
                color: s.color),
          ],
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionButton(
              key: Key('option_$i'),
              text: q.options[i],
              state: _picked == null
                  ? _OptState.idle
                  : i == q.answer
                      ? _OptState.right
                      : i == _picked
                          ? _OptState.wrong
                          : _OptState.idle,
              onTap: () => _pick(i),
            ),
          ),
        if (_picked != null) ...[
          const SizedBox(height: 6),
          Text(
            _picked == q.answer
                ? 'মাশাআল্লাহ! একদম ঠিক! 🌟'
                : 'চিন্তা নেই! সঠিক উত্তর সবুজ রঙে দেখানো হয়েছে। 💚',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          FilledButton(
            key: const Key('nextButton'),
            style: FilledButton.styleFrom(backgroundColor: s.color),
            onPressed: _next,
            child: Text(
                _index == _questions.length - 1 ? 'ফলাফল দেখি' : 'পরের প্রশ্ন'),
          ),
        ],
      ],
    );
  }

  Widget _result(Story s) {
    final total = _questions.length;
    final all = _correct == total;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(all ? '🏆' : '🌟', style: const TextStyle(fontSize: 90)),
        const SizedBox(height: 10),
        Text(
          all ? 'মাশাআল্লাহ! সব উত্তর সঠিক!' : 'বারাকাল্লাহু ফীক!',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text('${bn(total)}টির মধ্যে ${bn(_correct)}টি সঠিক',
            style: const TextStyle(fontSize: 20, color: AppColors.muted)),
        const SizedBox(height: 8),
        Text('তুমি পেয়েছ ${bn(3 + _correct)}টি তারা ⭐',
            style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 24),
        const Text(
          'চলো এখন একবার দরুদ পড়ি:\nসাল্লাল্লাহু আলাইহি ওয়াসাল্লাম',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, height: 1.6, color: AppColors.greenDark),
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: s.color),
          onPressed: () {
            AppScope.read(context).addDurood();
            Navigator.pop(context);
          },
          child: const Text('দরুদ পড়েছি, ফিরে যাই 💚'),
        ),
        TextButton(
          onPressed: () => setState(() {
            _index = 0;
            _correct = 0;
            _picked = null;
          }),
          child: const Text('আবার চেষ্টা করি'),
        ),
      ],
    );
  }
}

enum _OptState { idle, right, wrong }

class _OptionButton extends StatelessWidget {
  const _OptionButton(
      {super.key, required this.text, required this.state, required this.onTap});
  final String text;
  final _OptState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, icon) = switch (state) {
      _OptState.right => (
          const Color(0xFFE3F5EA),
          AppColors.green,
          Icons.check_circle_rounded
        ),
      _OptState.wrong => (
          const Color(0xFFFDECEA),
          const Color(0xFFD9534F),
          Icons.cancel_rounded
        ),
      _OptState.idle => (Colors.white, AppColors.sandDeep, null),
    };
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                  child: Text(text,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600))),
              if (icon != null) Icon(icon, color: border, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
