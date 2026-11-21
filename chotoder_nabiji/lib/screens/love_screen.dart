import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

const _prompts = [
  'আমি নবীজী ﷺ-কে ভালোবাসি, কারণ...',
  'জান্নাতে নবীজী ﷺ-এর সাথে দেখা হলে আমি বলব...',
  'নবীজী ﷺ-এর যে সুন্নাহটি আমি আজ পালন করেছি...',
  'নবীজী ﷺ-এর যে গল্পটি আমার সবচেয়ে প্রিয়...',
];

class LoveScreen extends StatefulWidget {
  const LoveScreen({super.key});

  @override
  State<LoveScreen> createState() => _LoveScreenState();
}

class _LoveScreenState extends State<LoveScreen> {
  final _controller = TextEditingController();
  int _prompt = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('নবীজীকে ভালোবাসার চিঠি')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'নবীজী ﷺ বলেছেন, "মানুষ তার সাথেই থাকবে, যাকে সে ভালোবাসে।" '
                  'তাই চলো, নবীজী ﷺ-এর জন্য মনের কথা লিখি, যেন জান্নাতে তাঁর সাথে থাকতে পারি!',
                  style: TextStyle(fontSize: 17, height: 1.6),
                ),
              ),
              const SourceNote('সহীহ বুখারী ৬১৬৮'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _prompts.length; i++)
                    ChoiceChip(
                      label: Text(_prompts[i]),
                      selected: _prompt == i,
                      onSelected: (_) => setState(() => _prompt = i),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('letterField'),
                controller: _controller,
                minLines: 4,
                maxLines: 8,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: _prompts[_prompt],
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('saveLetter'),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC2185B)),
                onPressed: () {
                  final t = _controller.text.trim();
                  if (t.isEmpty) return;
                  state.addLetter('${_prompts[_prompt]}\n$t');
                  _controller.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('মাশাআল্লাহ! তোমার চিঠি সংরক্ষিত হয়েছে 💌')));
                },
                icon: const Icon(Icons.favorite_rounded),
                label: const Text('চিঠি সংরক্ষণ করি'),
              ),
              const SizedBox(height: 24),
              if (state.letters.isNotEmpty)
                const Text('আমার চিঠিগুলো',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              for (final l in state.letters)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Card(
                    child: ListTile(
                      leading: const Text('💌', style: TextStyle(fontSize: 28)),
                      title: Text(l.text,
                          style: const TextStyle(fontSize: 16, height: 1.5)),
                      subtitle: Text(
                          bn('${l.date.day}/${l.date.month}/${l.date.year}'),
                          style: const TextStyle(color: AppColors.muted)),
                      trailing: IconButton(
                        tooltip: 'মুছে ফেলুন',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => state.deleteLetter(l),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
