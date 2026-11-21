import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  AgeGroup? _age;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 12),
                const Text('🕌', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 72)),
                const SizedBox(height: 8),
                const Text(
                  'ছোটদের নবীজী ﷺ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'চিনি · জানি · ভালোবাসি',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                const Text(
                  'অভিভাবকগণ, আপনার সন্তানের তথ্য দিন',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('nameField'),
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'সন্তানের নাম (ঐচ্ছিক)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('বয়স',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                for (final g in AgeGroup.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AgeTile(
                      group: g,
                      selected: _age == g,
                      onTap: () => setState(() => _age = g),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('startButton'),
                  onPressed: _age == null
                      ? null
                      : () {
                          final s = AppScope.read(context);
                          s.setChildName(_name.text);
                          s.setAgeGroup(_age!);
                        },
                  child: const Text('বিসমিল্লাহ, শুরু করি'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'এই অ্যাপ কোনো ব্যক্তিগত তথ্য সংগ্রহ করে না। '
                  'সব তথ্য শুধু এই ফোনেই থাকে।',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeTile extends StatelessWidget {
  const _AgeTile(
      {required this.group, required this.selected, required this.onTap});
  final AgeGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.green : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: selected ? AppColors.green : AppColors.sandDeep,
                width: 2),
          ),
          child: Row(
            children: [
              Text(group.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.label,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.ink)),
                    Text(group.range,
                        style: TextStyle(
                            fontSize: 15,
                            color:
                                selected ? Colors.white70 : AppColors.muted)),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
