// Design Ref: §2.1, §5.2 — app entry, lock gate, notification + scan bootstrap.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'core/notification/workmanager_callback.dart';
import 'core/providers.dart';
import 'features/lock/lock_screen.dart';
import 'features/settings/locale_controller.dart';
import 'features/tokens/token_list_page.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Block screenshots / recents preview for the sensitive vault (FLAG_SECURE).
  // (Applied natively in MainActivity; flag here documents intent.)

  final container = ProviderContainer();
  await container.read(notificationSchedulerProvider).init();

  // Background periodic scan is Android-only (workmanager). Desktop uses an
  // autostart + tray scheduler (win-3); guarded here to keep other platforms
  // from hitting MissingPluginException.
  if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher);
    await container.read(notificationSchedulerProvider).registerDailyScan();
  }

  // Load the saved language (null = follow system, English fallback).
  await container.read(localeControllerProvider.notifier).load();

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
