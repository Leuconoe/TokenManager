package sw2.io.tokenmanager

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity required by local_auth (BiometricPrompt).
// FLAG_SECURE blocks screenshots / recents thumbnail (Design §7). It is applied
// by default and can be toggled at runtime from Dart via [CHANNEL] so the user
// can opt out in Settings.
class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val CHANNEL = "sw2.io.tokenmanager/secure"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Secure by default; Dart re-applies the stored preference on startup.
        applySecure(true)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        applySecure(call.arguments as? Boolean ?: true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun applySecure(secure: Boolean) {
        if (secure) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
