package com.example.filmtrace_hk

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "filmtrace_hk/mapbox").setMethodCallHandler { call, result ->
            if (call.method == "getAccessToken") {
                val token = runCatching {
                    packageManager.getApplicationInfo(applicationContext.packageName, android.content.pm.PackageManager.GET_META_DATA)
                        .metaData?.getString("filmtrace_hk.mapbox_access_token") ?: ""
                }.getOrElse { "" }
                result.success(token)
            } else {
                result.notImplemented()
            }
        }
    }
}
