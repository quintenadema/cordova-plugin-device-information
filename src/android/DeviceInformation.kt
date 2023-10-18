package com.ademagroup.deviceinformation

import java.util.*
import android.Manifest
import org.json.JSONObject
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import android.content.BroadcastReceiver
import android.content.Intent
import android.content.IntentFilter
import android.os.*
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat.getSystemService
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaPlugin
import org.apache.cordova.PluginResult
import org.json.JSONArray
import java.io.File


class DeviceInformation : CordovaPlugin() {
	private val onCallbacks = HashMap<String, CallbackContext>()

	private val batteryReceiver = object : BroadcastReceiver() {
		override fun onReceive(context: Context?, intent: Intent?) {
			val status: Int = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
			val level: Int = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
			val scale: Int = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1

			val batteryLevel = level / scale.toDouble() * 100
			val batteryState: String = when (status) {
				BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
				BatteryManager.BATTERY_STATUS_DISCHARGING -> "unplugged"
				BatteryManager.BATTERY_STATUS_FULL -> "full"
				BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "unplugged"
				else -> "unknown"
			}

			val batteryData = JSONObject().apply {
				put("batteryLevel", batteryLevel)
				put("batteryState", batteryState)
			}

			callCallback("onBattery", batteryData)
		}
	}



	override fun execute(
		action: String,
		args: JSONArray,
		callbackContext: CallbackContext
	): Boolean {
		return when (action) {
			"device" -> {
				try {
					getDevice(callbackContext)
				} catch (e: Exception) {
					callbackContext.error("Error: ${e.message}")
				}
				true
			}
			"app" -> {
				try {
					getApp(callbackContext)
				} catch (e: Exception) {
					callbackContext.error("Error: ${e.message}")
				}
				true
			}
			"permissions" -> {
				try {
					getPermissions(callbackContext)
				} catch (e: Exception) {
					callbackContext.error("Error: ${e.message}")
				}
				true
			}
			"network" -> {
				try {
					getNetwork(callbackContext)
				} catch (e: Exception) {
					callbackContext.error("Error: ${e.message}")
				}
				true
			}
			"disk" -> {
				try {
					getDisk(callbackContext)
				} catch (e: Exception) {
					callbackContext.error("Error: ${e.message}")
				}
				true
			}
			"battery" -> {
				try {
					getBattery(callbackContext)
				} catch (e: Exception) {
					callbackContext.error("Error: ${e.message}")
				}
				true
			}
			"jailbreak" -> {
				try {
					getJailbreak(callbackContext)
				} catch (e: Exception) {
					callbackContext.error("Error: ${e.message}")
				}
				true
			}
			"setCallback" -> {
				try {
					val name = args.getString(0)
					setCallback(name, callbackContext)
				} catch (e: Exception) {
					callbackContext.error("Error: ${e.message}")
				}
				true
			}
			else -> false
		}
	}
	private fun getDevice(callbackContext: CallbackContext) {
		val returnData = JSONObject().apply {
			put("locale", JSONObject().apply {
				put("locale", Locale.getDefault().toString())
				put("preferredLanguages", JSONArray().put(Locale.getDefault().toString())) // Getting a list of preferred languages is not straightforward in Android, so here we're just repeating the default locale.
			})
			put("device", JSONObject().apply {
				put("model", Build.MODEL)
				put("systemVersion", Build.VERSION.RELEASE)
				put("name", Build.DEVICE)
			})
		}
		callbackContext.success(returnData)
	}
	private fun getApp(callbackContext: CallbackContext) {
		val returnData = JSONObject().apply {
			val packageManager: PackageManager = cordova.activity.packageManager
			val packageInfo: PackageInfo = packageManager.getPackageInfo(cordova.activity.packageName, 0)
			put("beta", false) // Android doesn't have a direct analog for beta check
			put("version", packageInfo.versionName ?: "N/A")
			put("bundle", cordova.activity.packageName ?: "N/A")
		}
		callbackContext.success(returnData)
	}
	private fun getPermissions(callbackContext: CallbackContext) {
		val returnData = JSONObject().apply {
			put("location", when {
				ContextCompat.checkSelfPermission(cordova.activity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED -> "authorized"
				else -> "notAuthorized"
			})
			put("contacts", when {
				ContextCompat.checkSelfPermission(cordova.activity, Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED -> "authorized"
				else -> "notAuthorized"
			})
			put("photos", when {
				ContextCompat.checkSelfPermission(cordova.activity, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED -> "authorized"
				else -> "notAuthorized"
			})
			put("calendar", when {
				ContextCompat.checkSelfPermission(cordova.activity, Manifest.permission.READ_CALENDAR) == PackageManager.PERMISSION_GRANTED -> "authorized"
				else -> "notAuthorized"
			})
			put("microphone", when {
				ContextCompat.checkSelfPermission(cordova.activity, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED -> "authorized"
				else -> "notAuthorized"
			})
			put("camera", when {
				ContextCompat.checkSelfPermission(cordova.activity, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED -> "authorized"
				else -> "notAuthorized"
			})
		}
		callbackContext.success(returnData)
	}
	private fun getNetwork(callbackContext: CallbackContext) {
		val telephonyManager = cordova.activity.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
		val returnData = JSONObject().apply {
			put("carrier", telephonyManager.networkOperatorName ?: "N/A")
			put("countryCode", telephonyManager.networkCountryIso ?: "N/A")
		}
		callbackContext.success(returnData)
	}
	private fun getDisk(callbackContext: CallbackContext) {
		val statFs = StatFs(Environment.getDataDirectory().path)
		val availableBlocksLong = statFs.availableBlocksLong
		val blockSizeLong = statFs.blockSizeLong
		val freeSpace = availableBlocksLong * blockSizeLong
		val returnData = JSONObject().apply {
			put("freeSpace", freeSpace)
		}
		callbackContext.success(returnData)
	}
	private fun getBattery(callbackContext: CallbackContext) {
		val batteryManager = getSystemService(cordova.activity, BatteryManager::class.java)
		val batteryState: String = when(batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_STATUS)) {
			BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
			BatteryManager.BATTERY_STATUS_DISCHARGING -> "unplugged"
			BatteryManager.BATTERY_STATUS_FULL -> "full"
			BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "unplugged"
			else -> "unknown"
		}
		val batteryLevel = batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)?.toDouble() ?: -1.0
		val returnData = JSONObject().apply {
			put("batteryLevel", batteryLevel)
			put("batteryState", batteryState)
		}
		callbackContext.success(returnData)
	}
	private fun getJailbreak(callbackContext: CallbackContext) {
		val isRooted = listOf(
			"/system/app/Superuser.apk",
			"/sbin/su",
			"/system/bin/su",
			"/system/xbin/su",
			"/data/local/xbin/su",
			"/data/local/bin/su",
			"/system/sd/xbin/su",
			"/system/bin/failsafe/su",
			"/data/local/su",
			"/su/bin/su"
		).any { path ->
			File(path).exists()
		}
		val returnData = JSONObject().apply {
			put("isJailbroken", isRooted)
		}
		callbackContext.success(returnData)
	}
	private fun setCallback(name: String, callbackContext: CallbackContext) {
		if (name == "onBattery") {
			if (onCallbacks[name] != null) {
				cordova.activity.unregisterReceiver(batteryReceiver)
			}
			cordova.activity.registerReceiver(batteryReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
		}
		onCallbacks[name] = callbackContext
	}
	private fun callCallback(callbackName: String, data: Any) {
		val callbackContext = onCallbacks[callbackName]
		if (callbackContext != null) {
			val pluginResult = when (data) {
				is JSONObject -> PluginResult(PluginResult.Status.OK, data)
				is Int -> PluginResult(PluginResult.Status.OK, data)
				else -> PluginResult(PluginResult.Status.OK, data.toString())
			}
			pluginResult.setKeepCallback(true)
			callbackContext.sendPluginResult(pluginResult)
		}
	}
}