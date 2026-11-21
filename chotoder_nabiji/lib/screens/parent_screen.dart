import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final stories = state.content.stories;
    return Scaffold(
      appBar: AppBar(title: const Text('অভিভাবক কর্নার')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section('সন্তানের অগ্রগতি'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row('পড়া গল্প',
                          '${bn(state.completedStories.length)} / ${bn(stories.length)}'),
                      _row('মোট তারা', bn(state.stars)),
                      _row('মোট দরুদ', bn(state.duroodTotal)),
                      _row('আজকের সুন্নাহ', bn(state.sunnahToday.length)),
                      _row('টানা সুন্নাহ পালন', '${bn(state.sunnahStreak)} দিন'),
                      _row('ভালোবাসার চিঠি', bn(state.letters.length)),
                    ],
                  ),
                ),
              ),
              _section('সেটিংস'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('বয়স গ্রুপ'),
                      subtitle: Text(
                          '${state.ageGroup?.label} (${state.ageGroup?.range})'),
                      trailing: DropdownButton<AgeGroup>(
                        value: state.ageGroup,
                        underline: const SizedBox(),
                        items: [
                          for (final g in AgeGroup.values)
                            DropdownMenuItem(
                                value: g, child: Text('${g.emoji} ${g.label}')),
                        ],
                        onChanged: (g) => g == null ? null : state.setAgeGroup(g),
                      ),
                    ),
                    ListTile(
                      title: const Text('বিরতির রিমাইন্ডার'),
                      subtitle: const Text('একটানা ব্যবহারের পর বিরতি নিতে বলবে'),
                      trailing: DropdownButton<int>(
                        value: state.dailyLimitMinutes,
                        underline: const SizedBox(),
                        items: [
                          for (final m in const [15, 20, 30, 45, 60, 0])
                            DropdownMenuItem(
                                value: m,
                                child: Text(m == 0 ? 'বন্ধ' : '${bn(m)} মিনিট')),
                        ],
                        onChanged: (m) =>
                            m == null ? null : state.setDailyLimit(m),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('শুনুন (অডিও) বোতাম'),
                      subtitle: const Text('ফোনের বাংলা ভয়েস দিয়ে পড়ে শোনাবে'),
                      value: state.ttsEnabled,
                      onChanged: state.setTts,
                    ),
                    ListTile(
                      leading: const Icon(Icons.restart_alt_rounded,
                          color: Colors.red),
                      title: const Text('সব অগ্রগতি মুছে ফেলুন'),
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('নিশ্চিত?'),
                            content: const Text(
                                'তারা, দরুদ গণনা, সুন্নাহ বাগান ও চিঠি সব মুছে যাবে।'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('না')),
                              FilledButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('হ্যাঁ, মুছুন')),
                            ],
                          ),
                        );
                        if (ok == true) state.resetProgress();
                      },
                    ),
                  ],
                ),
              ),
              _section('আজ রাতে সন্তানের সাথে আলোচনা করুন'),
              for (final s in stories)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    shape: const Border(),
                    leading: Text(s.emoji, style: const TextStyle(fontSize: 26)),
                    title: Text(s.title),
                    subtitle: state.completedStories.contains(s.id)
                        ? const Text('✓ পড়া হয়েছে',
                            style: TextStyle(color: AppColors.green))
                        : null,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• এই গল্পে নবীজী ﷺ-এর কোন গুণটি তোমার সবচেয়ে ভালো লেগেছে?',
                          style: const TextStyle(height: 1.6)),
                      Text('• শিক্ষা: ${s.lesson}',
                          style: const TextStyle(height: 1.6)),
                      Text('• এই শিক্ষাটি আমরা কাল কীভাবে পালন করতে পারি?',
                          style: const TextStyle(height: 1.6)),
                      SourceNote(s.source),
                    ],
                  ),
                ),
              _section('আমাদের নীতিমালা'),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '• রাসুলুল্লাহ ﷺ, নবী-রাসুল, উম্মাহাতুল মুমিনীন ও সাহাবিদের কোনো ছবি বা চিত্রায়ণ নেই।\n'
                    '• সব কনটেন্ট কুরআন, সহীহ হাদিস ও নির্ভরযোগ্য সীরাত গ্রন্থ থেকে নেওয়া, প্রতিটির সাথে সূত্র দেওয়া আছে।\n'
                    '• কোনো বাদ্যযন্ত্র নেই, কোনো বিজ্ঞাপন নেই।\n'
                    '• কোনো ব্যক্তিগত তথ্য সংগ্রহ বা কোথাও পাঠানো হয় না। সব তথ্য শুধু এই ফোনে থাকে।\n'
                    '• কোনো ভুল চোখে পড়লে আমাদের জানান, আমরা আলেমদের পরামর্শে সংশোধন করব।',
                    style: TextStyle(height: 1.7),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('সংস্করণ ১.০.০',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Text(t,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.greenDark)),
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(child: Text(k, style: const TextStyle(fontSize: 16))),
            Text(v,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
