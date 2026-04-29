import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../../progress/screens/progress_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final p = context.watch<ProgressProvider>().summary;

    return Scaffold(
      appBar: AppBar(title: const Text('ExamBank')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hi${user?.displayName != null ? ", ${user!.displayName}" : ""} 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Let’s practice for your admission test.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          if (p != null) _streakCard(context, p.streakDays, p.weeklyAccuracy),
          const SizedBox(height: 16),
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _tile(context, Icons.menu_book_rounded, 'Browse exams', () {
                // AppShell tab change would be cleaner; for v1 just rely on nav.
              }),
              _tile(context, Icons.auto_awesome_motion_rounded, 'Topic drill',
                  () {}),
              _tile(context, Icons.bookmark_rounded, 'Bookmarks', () {}),
              _tile(context, Icons.insights_outlined, 'Progress', () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProgressDashboardScreen(),
                ));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _streakCard(BuildContext context, int streak, double weekly) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.local_fire_department,
                color: Colors.deepOrange, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak day streak',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'This week: ${(weekly * 100).round()}% accuracy',
                    style: TextStyle(color: cs.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
