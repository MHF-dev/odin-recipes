import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../models.dart';
import '../speaker.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final stories = state.content.stories;
    return Scaffold(
      appBar: AppBar(title: const Text('নবীজীর গল্প')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: stories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final s = stories[i];
              final done = state.completedStories.contains(s.id);
              return Card(
                child: ListTile(
                  key: Key('story_${s.id}'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: EmojiBadge(s.emoji, background: s.lightColor),
                  title: Text('${bn(i + 1)}. ${s.title}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  subtitle: Text(s.period,
                      style: const TextStyle(color: AppColors.muted)),
                  trailing: done
                      ? const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 30)
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => StoryReaderScreen(index: i)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class StoryReaderScreen extends StatefulWidget {
  const StoryReaderScreen({super.key, required this.index});
  final int index;

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  @override
  void dispose() {
    Speaker.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final stories = state.content.stories;
    final Story s = stories[widget.index];
    final little = state.ageGroup == AgeGroup.little;
    final paragraphs = little ? [s.short] : s.paragraphs;
    final fontSize = little ? 22.0 : 19.0;
    final fullText = '${s.title}। ${paragraphs.join(' ')}';

    return Scaffold(
      backgroundColor: s.lightColor.withValues(alpha: 0.35),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: s.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.25,
              titlePadding: const EdgeInsetsDirectional.fromSTEB(56, 0, 16, 14),
              title: Text(s.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'HindSiliguri',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              background: _StoryCover(story: s),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Chip(label: Text(s.period)),
                          const Spacer(),
                          SpeakButton(text: fullText, color: s.color),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final p in paragraphs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(p,
                              style: TextStyle(
                                  fontSize: fontSize, height: 1.7)),
                        ),
                      _LessonCard(story: s),
                      SourceNote(s.source),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        key: const Key('quizButton'),
                        style: FilledButton.styleFrom(backgroundColor: s.color),
                        onPressed: () {
                          state.completeStory(s.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => QuizScreen(story: s)),
                          );
                        },
                        icon: const Icon(Icons.quiz_rounded),
                        label: const Text('গল্প শেষ! চলো প্রশ্নের উত্তর দিই'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (widget.index > 0)
                            TextButton.icon(
                              onPressed: () => _go(widget.index - 1),
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('আগের গল্প'),
                            ),
                          const Spacer(),
                          if (widget.index < stories.length - 1)
                            TextButton.icon(
                              onPressed: () {
                                state.completeStory(s.id);
                                _go(widget.index + 1);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('পরের গল্প'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _go(int i) {
    Speaker.instance.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => StoryReaderScreen(index: i)),
    );
  }
}

/// Illustrated cover without any human figure: only nature and places,
/// following the app's "no depiction" rule.
class _StoryCover extends StatelessWidget {
  const _StoryCover({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [story.color, story.color.withValues(alpha: 0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -40,
            right: -40,
            bottom: -60,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: story.lightColor.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.elliptical(400, 120)),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(story.emoji, style: const TextStyle(fontSize: 84)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟 আজকের শিক্ষা',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenDark)),
              const Spacer(),
              SpeakButton(text: story.lesson),
            ],
          ),
          Text(story.lesson, style: const TextStyle(fontSize: 18, height: 1.6)),
        ],
      ),
    );
  }
}
