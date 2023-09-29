import UIKit
import CoreTelephony
import CoreLocation

class DeviceInformation: CDVPlugin {
	private var currentCommand: CDVInvokedUrlCommand?
	private var onCallbacks = [String: String]()
	
	@objc func device(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		
		let returnData: [String: Any] = [
			"locale": [
				"locale": Locale.current.identifier,
				"preferredLanguages": Locale.preferredLanguages
			],
			"device": [
				"model": UIDevice.current.model,
				"systemVersion": UIDevice.current.systemVersion,
				"name": UIDevice.current.name
			]
		]
		
		sendPluginResult(true, data: returnData)
	}
	
	@objc func app(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		
		guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
			sendPluginResult(false, data: "Cannot detect installation method")
			return
		}
		
		let returnData: [String: Any] = [
			"installationMethod": appStoreReceiptURL.lastPathComponent == "sandboxReceipt" ? "testflight" : "store",
			"version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A",
			"bundle": Bundle.main.bundleIdentifier ?? "N/A"
		]
		
		sendPluginResult(true, data: returnData)
	}
	
	@objc func network(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		
		let networkInfo = CTTelephonyNetworkInfo()
		let carrier = networkInfo.subscriberCellularProvider
		
		let returnData: [String: Any] = [
			"carrier": carrier?.carrierName ?? "N/A",
			"countryCode": carrier?.mobileCountryCode ?? "N/A"
		]
		
		sendPluginResult(true, data: returnData)
	}
	
	@objc func disk(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		
		let fileManager = FileManager.default
		let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
		let systemAttributes = try? fileManager.attributesOfFileSystem(forPath: documentDirectory.path)
		let freeSpace = systemAttributes?[FileAttributeKey.systemFreeSize] as? NSNumber
		
		let returnData: [String: Any] = [
			"freeSpace": freeSpace ?? "N/A"
		]
		
		sendPluginResult(true, data: returnData)
	}
	
	@objc func battery(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		
		UIDevice.current.isBatteryMonitoringEnabled = true
		
		var batteryState: String
		switch UIDevice.current.batteryState {
			case .unknown:
				batteryState = "unknown"
			case .unplugged:
				batteryState = "unplugged"
			case .charging:
				batteryState = "charging"
			case .full:
				batteryState = "full"
			@unknown default:
				batteryState = "unkown"
		}
		
		let returnData: [String: Any] = [
			"batteryLevel": (UIDevice.current.batteryLevel * 100 * 100).rounded() / 100,
			"batteryState": batteryState
		]
		
		sendPluginResult(true, data: returnData)
	}
	
	@objc func jailbreak(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		
		let isJailbroken = FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
		
		let returnData: [String: Any] = [
			"isJailbroken": isJailbroken
		]
		
		sendPluginResult(true, data: returnData)
	}
	
	@objc func setCallback(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		
		guard let callbackName = command.arguments[0] as? String else {
			return sendPluginResult(false, data: "Invalid arguments")
		}
		
		self.onCallbacks[callbackName] = command.callbackId
	}
	func callCallback(_ callbackName: String, data: Any) {
		guard let callbackId = self.onCallbacks[callbackName] else {
			return
		}
		
		sendPluginResult(true, data: data, callbackId: callbackId)
	}
	
	
	func sendPluginResult(_ success: Bool, data: Any? = nil, callbackId: String? = nil) {
		var pluginResult: CDVPluginResult?
		let status = success ? CDVCommandStatus_OK : CDVCommandStatus_ERROR
		
		switch data {
		case let data as String:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as Int:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as CGFloat:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as Double:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as Bool:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as [Any]:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as [String: Any]:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case nil:
			pluginResult = CDVPluginResult(status: status)
		default:
			print("Unexpected data type: \(type(of: data))")
			return
		}
		
		pluginResult?.setKeepCallbackAs(true)
		self.commandDelegate?.send(pluginResult, callbackId: callbackId != nil ? callbackId : self.currentCommand?.callbackId)
	}
}
