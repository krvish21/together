import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/together_state.dart';
import 'widgets/couple_header_card.dart';
import 'widgets/quick_affection_bar.dart';
import 'widgets/daily_question_highlight.dart';
import 'widgets/active_game_nudge.dart';
import 'widgets/upcoming_plans_preview.dart';
import 'widgets/on_this_day_banner.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => state.refreshAll(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoupleHeaderCard(),
                SizedBox(height: 20),
                QuickAffectionBar(),
                SizedBox(height: 22),
                OnThisDayBanner(),
                SizedBox(height: 16),
                DailyQuestionHighlight(),
                SizedBox(height: 20),
                ActiveGameNudge(),
                SizedBox(height: 20),
                UpcomingPlansPreview(),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
