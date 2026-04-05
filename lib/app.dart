import 'package:clear_task/core/utils/theme/theme.dart';
import 'package:clear_task/presentation/blocs/auth/auth_cubit.dart';
import 'package:clear_task/presentation/blocs/credit/credit_cubit.dart';
import 'package:clear_task/presentation/blocs/sync/sync_cubit.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/blocs/theme/theme_cubit.dart';
import 'package:clear_task/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TaskBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => SyncCubit()),
        BlocProvider(create: (_) => CreditCubit()),
      ],
      child: Builder(
        builder: (ctx) {
          // Wire SyncCubit → TaskBloc so task CRUD auto-syncs
          final syncCubit = ctx.read<SyncCubit>();
          final taskBloc = ctx.read<TaskBloc>();
          taskBloc.setSyncCubit(syncCubit);

          // After cloud sync (especially pull), reload tasks in the UI
          syncCubit.onSyncComplete = () {
            taskBloc.add(FetchTasks());
          };

          return BlocListener<AuthCubit, AuthState>(
            listener: (context, authState) {
              if (authState.status == AuthStatus.authenticated) {
                final userId = authState.user!.uid;
                context.read<SyncCubit>().sync(userId);
                context.read<CreditCubit>().fetchCredit(userId);
                // 1. Grant daily credit (1 Credit)
                context.read<CreditCubit>().checkAndGrantDaily(userId);
                context.read<CreditCubit>().checkAndGrantDaily(userId);
              } else if (authState.status == AuthStatus.unauthenticated) {
                context.read<SyncCubit>().clearUser();
                context.read<CreditCubit>().clearCache();
              }
            },
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return GetMaterialApp(
                  title: 'ClearTask',
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeMode,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    FlutterQuillLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('en')],
                  home: const SplashScreen(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
