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
      // Launch via `cmd /c start` so the helper is fully spawned-and-forgotten
      // by the shell and survives this app exiting. (Process.start with
      // ProcessStartMode.detached on powershell does NOT reliably run the child.)
      await Process.start(
        'cmd',
        ['/c', 'start', '', '/min', 'powershell', '-NoProfile',
         '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', script.path],
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
\$ProgressPreference = 'SilentlyContinue'
\$log = Join-Path ${q(workDir)} 'update.log'
function Log(\$m) { "\$(Get-Date -Format o)  \$m" | Out-File -FilePath \$log -Append -Encoding utf8 }
Log "helper start pid=$myPid"
# Windows PowerShell 5.1 defaults to TLS 1.0/1.1; GitHub requires TLS 1.2.
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
try { Wait-Process -Id $myPid -Timeout 120 } catch {}
Start-Sleep -Seconds 1
\$zip = Join-Path ${q(workDir)} 'update.zip'
\$new = Join-Path ${q(workDir)} 'new'
\$ok = \$false
try {
  Log "download ${q(zipUrl)}"
  Invoke-WebRequest -Uri ${q(zipUrl)} -OutFile \$zip -UseBasicParsing
  Log "downloaded \$((Get-Item \$zip).Length) bytes; extracting"
  if (Test-Path \$new) { Remove-Item -Recurse -Force \$new }
  Expand-Archive -Path \$zip -DestinationPath \$new -Force
  Log "copying to ${q(installDir)}"
  Copy-Item -Path (Join-Path \$new '*') -Destination ${q(installDir)} -Recurse -Force
  \$ok = \$true
  Log "install OK"
} catch {
  Log "ERROR \$(\$_.Exception.Message)"
}
Log "relaunch (updated=\$ok)"
Start-Process -FilePath ${q(exePath)}
''';
  }
}
