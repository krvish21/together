import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import 'questions/questions_view.dart';
import 'games/games_view.dart';
import 'cute_messages/cute_messages_view.dart';

class UsTab extends StatefulWidget {
  const UsTab({super.key});

  @override
  State<UsTab> createState() => _UsTabState();
}

class _UsTabState extends State<UsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Us ❤️'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryRose,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryRose,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Questions', icon: Icon(Icons.forum_outlined, size: 20)),
            Tab(text: 'Games', icon: Icon(Icons.sports_esports_outlined, size: 20)),
            Tab(text: 'Affection', icon: Icon(Icons.favorite_outline_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          QuestionsView(),
          GamesView(),
          CuteMessagesView(),
        ],
      ),
    );
  }
}
