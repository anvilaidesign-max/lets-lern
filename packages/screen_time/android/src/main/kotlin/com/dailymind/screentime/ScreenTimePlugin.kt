package com.dailymind.screentime

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Reads today's screen time with UsageStatsManager (ARCHITECTURE.md 10.1).
 *
 * Registered as a regular Flutter plugin so it is also available in the
 * WorkManager background engine used for the 15-minute break check.
 *
 * Requires the special "Usage access" permission (PACKAGE_USAGE_STATS), which
 * the user grants manually in system settings.
 */
class ScreenTimePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var context: Context? = null
    private var executor: ExecutorService? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        executor = Executors.newSingleThreadExecutor()
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        executor?.shutdown()
        executor = null
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val ctx = context
        if (ctx == null) {
            result.error("unavailable", "Plugin is not attached.", null)
            return
        }
        when (call.method) {
            "hasPermission" -> result.success(hasPermission(ctx))
            "openPermissionSettings" -> {
                openPermissionSettings(ctx)
                result.success(null)
            }
            "getTodayUsage" -> runInBackground(result) {
                if (!hasPermission(ctx)) {
                    emptyList<Map<String, Any>>()
                } else {
                    todayUsage(ctx).map {
                        mapOf(
                            "packageName" to it.packageName,
                            "appName" to it.appName,
                            "minutes" to (it.millis / MINUTE).toInt(),
                        )
                    }
                }
            }
            "getTotalScreenTimeToday" -> runInBackground(result) {
                if (!hasPermission(ctx)) 0 else (todayUsage(ctx).sumOf { it.millis } / MINUTE).toInt()
            }
            "getContinuousUsageMinutes" -> runInBackground(result) {
                if (!hasPermission(ctx)) 0 else continuousUsageMinutes(ctx)
            }
            else -> result.notImplemented()
        }
    }

    private fun runInBackground(result: MethodChannel.Result, work: () -> Any) {
        val exec = executor
        if (exec == null) {
            result.error("unavailable", "Plugin is not attached.", null)
            return
        }
        exec.execute {
            try {
                val value = work()
                mainHandler.post { result.success(value) }
            } catch (e: Exception) {
                mainHandler.post { result.error("usage_error", e.message, null) }
            }
        }
    }

    private fun hasPermission(ctx: Context): Boolean {
        val appOps = ctx.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                ctx.packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                ctx.packageName,
            )
        }
        return if (mode == AppOpsManager.MODE_DEFAULT) {
            ctx.checkCallingOrSelfPermission(android.Manifest.permission.PACKAGE_USAGE_STATS) ==
                PackageManager.PERMISSION_GRANTED
        } else {
            mode == AppOpsManager.MODE_ALLOWED
        }
    }

    private fun openPermissionSettings(ctx: Context) {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            ctx.startActivity(intent)
        } catch (e: Exception) {
            // Some devices hide the page; fall back to the app's settings page.
            val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(android.net.Uri.fromParts("package", ctx.packageName, null))
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            ctx.startActivity(fallback)
        }
    }

    private data class AppUsage(val packageName: String, val appName: String, val millis: Long)

    private fun startOfToday(): Long = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    /** Launchers and system UI are not "screen time" the user chose. */
    private fun ignoredPackages(ctx: Context): Set<String> {
        val ignored = mutableSetOf("com.android.systemui")
        val home = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        val resolved = ctx.packageManager.resolveActivity(home, PackageManager.MATCH_DEFAULT_ONLY)
        resolved?.activityInfo?.packageName?.let { ignored.add(it) }
        return ignored
    }

    /**
     * Foreground time per app since midnight, built from activity resume and
     * pause events. This is more accurate than the daily buckets of
     * queryUsageStats, which can include time from before midnight.
     */
    private fun todayUsage(ctx: Context): List<AppUsage> {
        val usm = ctx.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val start = startOfToday()
        val now = System.currentTimeMillis()
        val events = usm.queryEvents(start, now)
        val event = UsageEvents.Event()
        val totals = HashMap<String, Long>()
        val resumedAt = HashMap<String, Long>()
        var lastResumedPackage: String? = null

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName ?: continue
            when (event.eventType) {
                EVENT_RESUMED -> {
                    if (!resumedAt.containsKey(pkg)) resumedAt[pkg] = event.timeStamp
                    lastResumedPackage = pkg
                }
                EVENT_PAUSED -> {
                    val opened = resumedAt.remove(pkg)
                    if (opened != null) {
                        totals[pkg] = (totals[pkg] ?: 0L) + (event.timeStamp - opened)
                    }
                    if (lastResumedPackage == pkg) lastResumedPackage = null
                }
            }
        }
        // Count the app that is still in the foreground right now.
        lastResumedPackage?.let { pkg ->
            resumedAt[pkg]?.let { opened -> totals[pkg] = (totals[pkg] ?: 0L) + (now - opened) }
        }

        val ignored = ignoredPackages(ctx)
        val pm = ctx.packageManager
        return totals
            .filter { (pkg, millis) -> pkg !in ignored && millis >= MINUTE }
            .map { (pkg, millis) -> AppUsage(pkg, appLabel(pm, pkg), millis) }
            .sortedByDescending { it.millis }
    }

    private fun appLabel(pm: PackageManager, pkg: String): String = try {
        pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
    } catch (e: Exception) {
        pkg
    }

    /**
     * Minutes since the screen last turned on, if it is still on. Uses the
     * SCREEN_INTERACTIVE / SCREEN_NON_INTERACTIVE events (Android 9+).
     */
    private fun continuousUsageMinutes(ctx: Context): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return 0
        val usm = ctx.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val events = usm.queryEvents(now - 12 * 60 * MINUTE, now)
        val event = UsageEvents.Event()
        var screenOnSince: Long? = null
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            when (event.eventType) {
                UsageEvents.Event.SCREEN_INTERACTIVE -> screenOnSince = event.timeStamp
                UsageEvents.Event.SCREEN_NON_INTERACTIVE -> screenOnSince = null
            }
        }
        val since = screenOnSince ?: return 0
        return ((now - since) / MINUTE).toInt()
    }

    companion object {
        private const val CHANNEL = "daily_mind/screen_time"
        private const val MINUTE = 60_000L
        // ACTIVITY_RESUMED / ACTIVITY_PAUSED (API 29) share these values with
        // the older MOVE_TO_FOREGROUND / MOVE_TO_BACKGROUND constants.
        private const val EVENT_RESUMED = 1
        private const val EVENT_PAUSED = 2
    }
}
