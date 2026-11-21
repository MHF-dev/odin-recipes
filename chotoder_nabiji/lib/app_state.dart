import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Age groups described in the plan.
enum AgeGroup {
  little('অঙ্কুর', '৩–৬ বছর', '🌱'),
  middle('কুঁড়ি', '৭–১০ বছর', '🌿'),
  big('ফুল', '১১–১৩ বছর', '🌸');

  final String label;
  final String range;
  final String emoji;
  const AgeGroup(this.label, this.range, this.emoji);
}

class LoveLetter {
  final String text;
  final DateTime date;
  const LoveLetter(this.text, this.date);

  Map<String, dynamic> toJson() => {'t': text, 'd': date.toIso8601String()};
  factory LoveLetter.fromJson(Map<String, dynamic> j) =>
      LoveLetter(j['t'] as String, DateTime.parse(j['d'] as String));
}

String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Everything about the child's progress. Stored only on the device —
/// no personal data ever leaves the phone.
class AppState extends ChangeNotifier {
  AppState(this._prefs, this.content) {
    _read();
  }

  final SharedPreferences _prefs;
  final Content content;

  AgeGroup? ageGroup;
  String childName = '';
  final Set<String> completedStories = {};
  final Map<String, int> quizBest = {};
  int duroodTotal = 0;
  final Map<String, int> duroodByDay = {};
  final Map<String, Set<String>> sunnahByDay = {};
  final List<LoveLetter> letters = [];
  int dailyLimitMinutes = 30;
  bool ttsEnabled = true;

  // ---- persistence ----
  void _read() {
    final age = _prefs.getInt('age');
    ageGroup = age == null ? null : AgeGroup.values[age];
    childName = _prefs.getString('name') ?? '';
    completedStories.addAll(_prefs.getStringList('stories') ?? const []);
    final qb = _prefs.getString('quizBest');
    if (qb != null) {
      (jsonDecode(qb) as Map<String, dynamic>)
          .forEach((k, v) => quizBest[k] = v as int);
    }
    duroodTotal = _prefs.getInt('duroodTotal') ?? 0;
    final dd = _prefs.getString('duroodByDay');
    if (dd != null) {
      (jsonDecode(dd) as Map<String, dynamic>)
          .forEach((k, v) => duroodByDay[k] = v as int);
    }
    final sd = _prefs.getString('sunnahByDay');
    if (sd != null) {
      (jsonDecode(sd) as Map<String, dynamic>).forEach(
          (k, v) => sunnahByDay[k] = Set<String>.from(v as List<dynamic>));
    }
    final ls = _prefs.getString('letters');
    if (ls != null) {
      letters.addAll((jsonDecode(ls) as List<dynamic>)
          .map((e) => LoveLetter.fromJson(e as Map<String, dynamic>)));
    }
    dailyLimitMinutes = _prefs.getInt('limit') ?? 30;
    ttsEnabled = _prefs.getBool('tts') ?? true;
  }

  Future<void> _save() async {
    if (ageGroup != null) await _prefs.setInt('age', ageGroup!.index);
    await _prefs.setString('name', childName);
    await _prefs.setStringList('stories', completedStories.toList());
    await _prefs.setString('quizBest', jsonEncode(quizBest));
    await _prefs.setInt('duroodTotal', duroodTotal);
    await _prefs.setString('duroodByDay', jsonEncode(duroodByDay));
    await _prefs.setString(
      'sunnahByDay',
      jsonEncode(sunnahByDay.map((k, v) => MapEntry(k, v.toList()))),
    );
    await _prefs.setString(
        'letters', jsonEncode(letters.map((e) => e.toJson()).toList()));
    await _prefs.setInt('limit', dailyLimitMinutes);
    await _prefs.setBool('tts', ttsEnabled);
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  // ---- derived values ----
  int get stars =>
      completedStories.length * 3 +
      quizBest.values.fold<int>(0, (a, b) => a + b) +
      sunnahByDay.values.fold<int>(0, (a, s) => a + s.length);

  String get todayKey => dateKey(DateTime.now());
  int get duroodToday => duroodByDay[todayKey] ?? 0;
  Set<String> get sunnahToday => sunnahByDay[todayKey] ?? <String>{};
  int get totalFlowers =>
      sunnahByDay.values.fold<int>(0, (a, s) => a + s.length);

  /// Consecutive days (ending today or yesterday) with at least one sunnah.
  int get sunnahStreak {
    var day = DateTime.now();
    if ((sunnahByDay[dateKey(day)] ?? const {}).isEmpty) {
      day = day.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while ((sunnahByDay[dateKey(day)] ?? const {}).isNotEmpty) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // ---- actions ----
  void setAgeGroup(AgeGroup g) {
    ageGroup = g;
    _changed();
  }

  void setChildName(String n) {
    childName = n.trim();
    _changed();
  }

  void completeStory(String id) {
    if (completedStories.add(id)) _changed();
  }

  void recordQuiz(String storyId, int correct) {
    if (correct > (quizBest[storyId] ?? -1)) {
      quizBest[storyId] = correct;
      _changed();
    }
  }

  void addDurood([int n = 1]) {
    duroodTotal += n;
    duroodByDay[todayKey] = duroodToday + n;
    _changed();
  }

  void toggleSunnah(String id) {
    final s = sunnahByDay.putIfAbsent(todayKey, () => <String>{});
    if (!s.remove(id)) s.add(id);
    _changed();
  }

  void addLetter(String text) {
    letters.insert(0, LoveLetter(text.trim(), DateTime.now()));
    _changed();
  }

  void deleteLetter(LoveLetter l) {
    letters.remove(l);
    _changed();
  }

  void setDailyLimit(int minutes) {
    dailyLimitMinutes = minutes;
    _changed();
  }

  void setTts(bool v) {
    ttsEnabled = v;
    _changed();
  }

  Future<void> resetProgress() async {
    completedStories.clear();
    quizBest.clear();
    duroodTotal = 0;
    duroodByDay.clear();
    sunnahByDay.clear();
    letters.clear();
    _changed();
  }
}

/// Makes [AppState] available to the widget tree without extra packages.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
