// Windows in-place auto-update. The running app cannot overwrite its own
// exe/dlls, so we drop a detached PowerShell helper that waits for this process
// to exit, downloads + extracts the release zip over the install directory, and
// relaunches — then we quit. Windows-only.

import 'dart:io';

import '../debug/debug_log.dart';

class WindowsUpdater {
  /// Launches the updater helper for [zipUrl] and exits the app.
  /// Returns false (without exiting) if it couldn't even start the helper.
  static Future<bool> downloadInstallAndRestart(String zipUrl) async {
    if (!Platform.isWindows || zipUrl.isEmpty) return false;
    final exePath = Platform.resolvedExecutable;
    final installDir = File(exePath).parent.path;
    final work = Directory('${Platform.environment['TEMP'] ?? installDir}'
        '\\tokenmanager_update');
    try {
      work.createSync(recursive: true);
      final script = File('${work.path}\\update.ps1');
      script.writeAsStringSync(_script(
        myPid: pid,
        zipUrl: zipUrl,
        installDir: installDir,
        exePath: exePath,
        workDir: work.path,
      ));
      dlog('update: launching Windows updater helper');
      await Process.start(
        'powershell',
        ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden',
         '-File', script.path],
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      dlog('update: failed to launch helper $e');
      return false;
    }
    // Give the helper a moment to start waiting on our PID, then quit so it can
    // replace the files.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    exit(0);
  }

  // PowerShell, with values interpolated as single-quoted literals (doubled
  // single-quotes for escaping).
  static String _script({
    required int myPid,
    required String zipUrl,
    required String installDir,
    required String exePath,
    required String workDir,
  }) {
    String q(String s) => "'${s.replaceAll("'", "''")}'";
    return '''
\$ErrorActionPreference = 'Stop'
\$ProgressPreference = 'SilentlyContinue'
try { Wait-Process -Id $myPid -Timeout 120 } catch {}
Start-Sleep -Seconds 1
\$zip = Join-Path ${q(workDir)} 'update.zip'
\$new = Join-Path ${q(workDir)} 'new'
try {
  Invoke-WebRequest -Uri ${q(zipUrl)} -OutFile \$zip
  if (Test-Path \$new) { Remove-Item -Recurse -Force \$new }
  Expand-Archive -Path \$zip -DestinationPath \$new -Force
  Copy-Item -Path (Join-Path \$new '*') -Destination ${q(installDir)} -Recurse -Force
} catch {
  # On failure just relaunch the existing version.
}
Start-Process -FilePath ${q(exePath)}
''';
  }
}
