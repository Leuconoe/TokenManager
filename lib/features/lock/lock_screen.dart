// Design Ref: §F4, §5.2 — entry lock gate. Data is not shown until unlocked.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _authenticating = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _failed = false;
    });
    final reason = AppLocalizations.of(context).lockReason;
    final ok =
        await ref.read(biometricServiceProvider).authenticate(reason: reason);
    if (!mounted) return;
    if (ok) {
      ref.read(appUnlockedProvider.notifier).state = true;
    } else {
      setState(() {
        _authenticating = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 72),
            const SizedBox(height: 16),
            Text(l.appTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_failed ? l.lockAuthFailed : l.lockAuthRequired,
                style: TextStyle(color: _failed ? Colors.red : null)),
            const SizedBox(height: 24),
            if (_authenticating)
              const CircularProgressIndicator()
            else
              FilledButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: Text(l.lockUnlock),
              ),
          ],
        ),
      ),
    );
  }
}
