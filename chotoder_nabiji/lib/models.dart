import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart' show Color;

Color hexColor(String hex) =>
    Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answer;

  const QuizQuestion(this.question, this.options, this.answer);

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
        j['q'] as String,
        List<String>.from(j['options'] as List),
        j['answer'] as int,
      );
}

class Story {
  final String id;
  final String title;
  final String period;
  final String emoji;
  final Color color;
  final Color lightColor;
  final String short;
  final List<String> paragraphs;
  final String lesson;
  final String source;
  final List<QuizQuestion> quiz;

  const Story({
    required this.id,
    required this.title,
    required this.period,
    required this.emoji,
    required this.color,
    required this.lightColor,
    required this.short,
    required this.paragraphs,
    required this.lesson,
    required this.source,
    required this.quiz,
  });

  factory Story.fromJson(Map<String, dynamic> j) {
    final colors = List<String>.from(j['colors'] as List);
    return Story(
      id: j['id'] as String,
      title: j['title'] as String,
      period: j['period'] as String,
      emoji: j['emoji'] as String,
      color: hexColor(colors[0]),
      lightColor: hexColor(colors[1]),
      short: j['short'] as String,
      paragraphs: List<String>.from(j['paragraphs'] as List),
      lesson: j['lesson'] as String,
      source: j['source'] as String,
      quiz: (j['quiz'] as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ShamailCard {
  final String id, emoji, title, text, source;
  const ShamailCard(this.id, this.emoji, this.title, this.text, this.source);

  factory ShamailCard.fromJson(Map<String, dynamic> j) => ShamailCard(
        j['id'] as String,
        j['emoji'] as String,
        j['title'] as String,
        j['text'] as String,
        j['source'] as String,
      );
}

class Dua {
  final String id, category, title, arabic, pronunciation, meaning, when, source;
  const Dua({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.pronunciation,
    required this.meaning,
    required this.when,
    required this.source,
  });

  factory Dua.fromJson(Map<String, dynamic> j) => Dua(
        id: j['id'] as String,
        category: j['category'] as String,
        title: j['title'] as String,
        arabic: j['arabic'] as String,
        pronunciation: j['pronunciation'] as String,
        meaning: j['meaning'] as String,
        when: j['when'] as String,
        source: j['source'] as String,
      );
}

class Sunnah {
  final String id, emoji, flower, title, hadith, source;
  const Sunnah(
      this.id, this.emoji, this.flower, this.title, this.hadith, this.source);

  factory Sunnah.fromJson(Map<String, dynamic> j) => Sunnah(
        j['id'] as String,
        j['emoji'] as String,
        j['flower'] as String,
        j['title'] as String,
        j['hadith'] as String,
        j['source'] as String,
      );
}

class FamilyMember {
  final String name, relation, note;
  const FamilyMember(this.name, this.relation, this.note);
}

class FamilyGroup {
  final String group, emoji;
  final List<FamilyMember> members;
  const FamilyGroup(this.group, this.emoji, this.members);

  factory FamilyGroup.fromJson(Map<String, dynamic> j) => FamilyGroup(
        j['group'] as String,
        j['emoji'] as String,
        (j['members'] as List)
            .map((m) => FamilyMember(
                  m['name'] as String,
                  m['relation'] as String,
                  m['note'] as String,
                ))
            .toList(),
      );
}

/// All bundled, offline content of the app.
class Content {
  final List<Story> stories;
  final List<ShamailCard> shamail;
  final List<Dua> duas;
  final List<Sunnah> sunnah;
  final List<FamilyGroup> family;

  const Content({
    required this.stories,
    required this.shamail,
    required this.duas,
    required this.sunnah,
    required this.family,
  });

  static Future<List<dynamic>> _load(String name) async =>
      jsonDecode(await rootBundle.loadString('assets/data/$name.json'))
          as List<dynamic>;

  static Future<Content> load() async {
    final r = await Future.wait([
      _load('stories'),
      _load('shamail'),
      _load('duas'),
      _load('sunnah'),
      _load('family'),
    ]);
    Map<String, dynamic> m(dynamic e) => e as Map<String, dynamic>;
    return Content(
      stories: r[0].map((e) => Story.fromJson(m(e))).toList(),
      shamail: r[1].map((e) => ShamailCard.fromJson(m(e))).toList(),
      duas: r[2].map((e) => Dua.fromJson(m(e))).toList(),
      sunnah: r[3].map((e) => Sunnah.fromJson(m(e))).toList(),
      family: r[4].map((e) => FamilyGroup.fromJson(m(e))).toList(),
    );
  }
}
