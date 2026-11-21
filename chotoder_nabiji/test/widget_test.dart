import 'dart:convert';
import 'dart:io';

import 'package:chotoder_nabiji/app_state.dart';
import 'package:chotoder_nabiji/main.dart';
import 'package:chotoder_nabiji/models.dart';
import 'package:chotoder_nabiji/speaker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<dynamic> _json(String name) =>
    jsonDecode(File('assets/data/$name.json').readAsStringSync())
        as List<dynamic>;

Content _content() {
  Map<String, dynamic> m(dynamic e) => e as Map<String, dynamic>;
  return Content(
    stories: _json('stories').map((e) => Story.fromJson(m(e))).toList(),
    shamail: _json('shamail').map((e) => ShamailCard.fromJson(m(e))).toList(),
    duas: _json('duas').map((e) => Dua.fromJson(m(e))).toList(),
    sunnah: _json('sunnah').map((e) => Sunnah.fromJson(m(e))).toList(),
    family: _json('family').map((e) => FamilyGroup.fromJson(m(e))).toList(),
  );
}

Future<AppState> _state([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  return AppState(await SharedPreferences.getInstance(), _content());
}

void main() {
  group('content', () {
    test('every quiz answer index is valid and every item has a source', () {
      final c = _content();
      expect(c.stories.length, greaterThanOrEqualTo(14));
      for (final s in c.stories) {
        expect(s.source, isNotEmpty, reason: s.id);
        expect(s.quiz, isNotEmpty, reason: s.id);
        for (final q in s.quiz) {
          expect(q.answer, inInclusiveRange(0, q.options.length - 1),
              reason: '${s.id}: ${q.question}');
        }
      }
      for (final d in c.duas) {
        expect(d.source, isNotEmpty, reason: d.id);
      }
      for (final s in c.sunnah) {
        expect(s.source, isNotEmpty, reason: s.id);
      }
    });

    test('ids are unique', () {
      final c = _content();
      final ids = [
        ...c.stories.map((e) => e.id),
        ...c.shamail.map((e) => e.id),
        ...c.duas.map((e) => e.id),
        ...c.sunnah.map((e) => e.id),
      ];
      expect(ids.toSet().length, ids.length);
    });
  });

  group('state', () {
    test('progress is saved and restored', () async {
      final s = await _state();
      s.setAgeGroup(AgeGroup.middle);
      s.completeStory('s01_birth');
      s.recordQuiz('s01_birth', 2);
      s.addDurood(3);
      s.toggleSunnah('su01');
      s.addLetter('ভালোবাসি');
      await Future<void>.delayed(Duration.zero);

      final restored =
          AppState(await SharedPreferences.getInstance(), s.content);
      expect(restored.ageGroup, AgeGroup.middle);
      expect(restored.completedStories, contains('s01_birth'));
      expect(restored.duroodTotal, 3);
      expect(restored.duroodToday, 3);
      expect(restored.sunnahToday, contains('su01'));
      expect(restored.letters.single.text, 'ভালোবাসি');
      expect(restored.stars, 3 + 2 + 1);
      expect(restored.sunnahStreak, 1);
    });

    test('toggling a sunnah twice removes it', () async {
      final s = await _state();
      s.toggleSunnah('su02');
      s.toggleSunnah('su02');
      expect(s.sunnahToday, isEmpty);
    });
  });

  test('speaker spells out honorifics', () {
    expect(Speaker.prepare('নবীজী ﷺ ও আবু বকর (রা.)'),
        'নবীজী সাল্লাল্লাহু আলাইহি ওয়াসাল্লাম ও আবু বকর রাদিয়াল্লাহু আনহু');
  });

  testWidgets('onboarding leads to home and a story can be read and quizzed',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final state = await _state({'tts': false});
    await tester.pumpWidget(ChotoderNabijiApp(state: state));
    expect(find.text('বিসমিল্লাহ, শুরু করি'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('nameField')), 'আমিনা');
    await tester.tap(find.text('কুঁড়ি'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('startButton')));
    await tester.pumpAndSettle();
    expect(find.text('আসসালামু আলাইকুম, আমিনা!'), findsOneWidget);

    await tester.tap(find.text('নবীজীর গল্প'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story_s01_birth')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('quizButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quizButton')));
    await tester.pumpAndSettle();
    expect(state.completedStories, contains('s01_birth'));

    for (final q in state.content.stories.first.quiz) {
      await tester.tap(find.byKey(Key('option_${q.answer}')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('nextButton')));
      await tester.pumpAndSettle();
    }
    expect(find.text('মাশাআল্লাহ! সব উত্তর সঠিক!'), findsOneWidget);
    expect(state.quizBest['s01_birth'], 3);
  });

  testWidgets('durood counter and sunnah garden update state', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final state = await _state({'age': 0, 'tts': false});
    await tester.pumpWidget(ChotoderNabijiApp(state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.text('দরুদ ও দোয়া'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('duroodButton')));
    await tester.tap(find.byKey(const Key('duroodButton')));
    await tester.pump();
    expect(state.duroodToday, 2);
    expect(find.text('২'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('সুন্নাহ বাগান'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sunnah_su01')));
    await tester.pump();
    expect(state.sunnahToday, contains('su01'));
  });
}
