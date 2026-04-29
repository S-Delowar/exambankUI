import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/bookmarks/providers/bookmark_provider.dart';
import 'features/bookmarks/repository/bookmark_repository.dart';
import 'features/drill/providers/drill_provider.dart';
import 'features/exams/repository/exam_repository.dart';
import 'features/practice/repository/practice_repository.dart';
import 'features/progress/providers/progress_provider.dart';
import 'features/progress/repository/progress_repository.dart';

class ExamBankApp extends StatelessWidget {
  const ExamBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = TokenStorage();
    final api = ApiClient(tokens);

    return MultiProvider(
      providers: [
        // Singletons / services.
        Provider<TokenStorage>.value(value: tokens),
        Provider<ApiClient>.value(value: api),

        // Repositories.
        Provider<AuthRepository>(
          create: (_) => AuthRepository(api, tokens),
        ),
        Provider<ExamRepository>(
          create: (_) => ExamRepository(api),
        ),
        Provider<PracticeRepository>(
          create: (_) => PracticeRepository(api),
        ),
        Provider<BookmarkRepository>(
          create: (_) => BookmarkRepository(api),
        ),
        Provider<ProgressRepository>(
          create: (_) => ProgressRepository(api),
        ),

        // Root-level ChangeNotifier providers.
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider()..bootstrap(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(
            ctx.read<AuthRepository>(),
            tokens,
            api,
          ),
        ),
        ChangeNotifierProvider<BookmarkProvider>(
          create: (ctx) =>
              BookmarkProvider(ctx.read<BookmarkRepository>(), api),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (ctx) =>
              ProgressProvider(ctx.read<ProgressRepository>(), api),
        ),
        ChangeNotifierProvider<DrillProvider>(
          create: (_) => DrillProvider(api),
        ),
      ],
      child: MaterialApp(
        title: 'ExamBank',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
