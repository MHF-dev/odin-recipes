import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'models.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    Content.load(),
  ]);
  final state = AppState(results[0] as SharedPreferences, results[1] as Content);
  runApp(ChotoderNabijiApp(state: state));
}

class ChotoderNabijiApp extends StatelessWidget {
  const ChotoderNabijiApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'ছোটদের নবীজী',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        navigatorKey: ScreenTimeGuard.navigatorKey,
        builder: (context, child) => ScreenTimeGuard(child: child!),
        home: const RootScreen(),
      ),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return state.ageGroup == null
        ? const OnboardingScreen()
        : const HomeScreen();
  }
}

/// Gently reminds the child to take a break after the time limit the
/// parent chose — in the spirit of the Sunnah, not as a punishment.
class ScreenTimeGuard extends StatefulWidget {
  const ScreenTimeGuard({super.key, required this.child});
  final Widget child;

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<ScreenTimeGuard> createState() => _ScreenTimeGuardState();
}

class _ScreenTimeGuardState extends State<ScreenTimeGuard>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _activeMinutes = 0;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
  }

  void _tick() {
    _activeMinutes++;
    final limit = AppScope.read(context).dailyLimitMinutes;
    if (limit > 0 && _activeMinutes >= limit && !_showing) {
      _activeMinutes = 0;
      _showBreak();
    }
  }

  Future<void> _showBreak() async {
    final ctx = ScreenTimeGuard.navigatorKey.currentContext;
    if (ctx == null) return;
    _showing = true;
    await showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('🌿 একটু বিরতি নেওয়ার সময়!'),
        content: const Text(
          'চলো এবার নবীজী ﷺ-এর মতো আব্বু-আম্মুকে ঘরের কাজে সাহায্য করি, '
          'অথবা কাউকে হাসিমুখে সালাম দিই!',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('ইনশাআল্লাহ'),
          ),
        ],
      ),
    );
    _showing = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      _start();
    } else if (s == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
