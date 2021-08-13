package com.sparsh.cmplmange
import androidx.annotation.NonNull

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.pm.PackageManager
import android.content.Intent
import android.net.Uri

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "checkAppInstalled"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            if (call.method == "checkPackageExists"){
                val packageName =  call.argument<String>("packageName")
                val isPackageInstalled = isAppInstalled(packageName.toString(), this)
                result.success(isPackageInstalled)
            } else if (call.method == "uninstallPackage"){
                val packageName =  call.argument<String>("packageName")
                val isUninstalled = uninstallApplication(packageName.toString(), this)
                result.success(isUninstalled)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isAppInstalled(packageName: String, context: Context): Boolean {
        return try {
            val packageManager = context.packageManager
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun uninstallApplication(packageName: String, context: Context): Boolean {
        return try {
            if(isAppInstalled(packageName, this)) {
            val intent = Intent(Intent.ACTION_DELETE)
            intent.setData(Uri.parse("package:$packageName"))
            startActivity(intent)
            }
            return isAppInstalled(packageName, this)
        } catch (e: ActivityNotFoundException) {
            false
        }
    }
}
