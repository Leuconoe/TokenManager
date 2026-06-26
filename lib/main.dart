// Design Ref: §2.1, §5.2 — app entry, lock gate, notification + scan bootstrap.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'core/platform/secure_screen.dart';
import 'core/providers.dart';
import 'features/lock/lock_screen.dart';
import 'features/settings/locale_controller.dart';
import 'features/tokens/token_list_page.dart';
import 'l10n/app_localizations.dart';

bool get _isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Block screenshots / recents preview for the sensitive vault (FLAG_SECURE).
  // Secure by default natively in MainActivity; re-apply the user preference
  // (Android lets the user opt out in Settings).
  await SecureScreen.apply(
      await container.read(settingsRepositoryProvider).getCaptureProtection());

  // Desktop: tray-resident window shell.
  if (_isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(440, 760),
        title: 'TokenManager',
        titleBarStyle: TitleBarStyle.normal,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  await container.read(notificationSchedulerProvider).init();

  // Platform-branched scan scheduling (Android=WorkManager, Desktop=tray+startup).
  final scheduler = container.read(scanSchedulerProvider);
  await scheduler.ensureScheduled();
  // Desktop has no background worker → scan on launch. Android relies on the
  // periodic WorkManager task (avoids notification spam on every app open).
  if (_isDesktop) await scheduler.runOnce();

  // Load the saved language (null = follow system, English fallback).
  await container.read(localeControllerProvider.notifier).load();

  // Folder sync: pull + merge on launch (no-op if disabled/not configured).
  await container.read(syncControllerProvider).syncQuietly();

  // Auto-sync heartbeat (5 min / 1 hour cadence while enabled).
  container.read(periodicSyncProvider).start();

  // Skip the lock gate on devices with no secure lock screen (no biometric
  // and no device credential) — otherwise the user would be stuck. Data
  // remains encrypted at rest regardless.
  final lockable = await container.read(biometricServiceProvider).canAuthenticate();
  if (!lockable) {
    container.read(appUnlockedProvider.notifier).state = true;
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const TokenManagerApp(),
  ));
}

class TokenManagerApp extends ConsumerWidget {
  const TokenManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(appUnlockedProvider);
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale, // null = follow system
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Follow system locale, but fall back to English (not the first
      // supported locale) when the device language isn't supported.
      localeResolutionCallback: (device, supported) {
        if (locale != null) return locale;
        if (device != null) {
          for (final s in supported) {
            if (s.languageCode == device.languageCode &&
                (s.scriptCode == null || s.scriptCode == device.scriptCode)) {
              return s;
            }
          }
        }
        return const Locale('en');
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: unlocked ? const TokenListPage() : const LockScreen(),
    );
  }
}
