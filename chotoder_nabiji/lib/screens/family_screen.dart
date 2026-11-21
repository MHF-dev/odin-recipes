import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = AppScope.of(context).content.family;
    return Scaffold(
      appBar: AppBar(title: const Text('নবীজী ﷺ-এর পরিবার')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  children: [
                    Text('🕌', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 4),
                    Text('মুহাম্মাদ ﷺ',
                        style: TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    Text('ইবনে আব্দুল্লাহ ইবনে আব্দুল মুত্তালিব ইবনে হাশিম',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final g in groups)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      shape: const Border(),
                      leading: EmojiBadge(g.emoji, size: 46),
                      title: Text(g.group,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      subtitle: Text('${bn(g.members.length)} জন',
                          style: const TextStyle(color: AppColors.muted)),
                      children: [
                        for (final m in g.members)
                          ListTile(
                            title: Text(m.name,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text('${m.relation} · ${m.note}',
                                style: const TextStyle(height: 1.5)),
                            trailing: SpeakButton(
                                text: '${m.name}, ${m.relation}। ${m.note}'),
                          ),
                      ],
                    ),
                  ),
                ),
              const SourceNote('আর-রাহীকুল মাখতূম; সীরাতে ইবনে হিশাম; সহীহ বুখারী ও মুসলিম'),
            ],
          ),
        ),
      ),
    );
  }
}
