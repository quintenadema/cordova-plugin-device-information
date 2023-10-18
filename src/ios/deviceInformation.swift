import UIKit
import Foundation
import CoreTelephony
import CoreLocation
import Contacts
import Photos
import HealthKit
import EventKit
import AVFoundation
import MediaPlayer

class DeviceInformation: CDVPlugin {
	private var currentCommand: CDVInvokedUrlCommand?
	private var onCallbacks = [String: String]()
	
	override func pluginInitialize() {
		super.pluginInitialize()
		
		self.onCallbacks = [:]
		
		// Enable battery monitoring
		UIDevice.current.isBatteryMonitoringEnabled = true
		
		// Add observers for battery level and state changes
		NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
	}
	@objc func batteryLevelDidChange(_ notification: Notification) {
		callCallback("onBattery", data: getBattery())
	}
	
	@objc func batteryStateDidChange(_ notification: Notification) {
		callCallback("onBattery", data: getBattery())
	}
	
	
	@objc func device(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		sendPluginResult(true, data: getDevice())
	}
	func getDevice() -> [String: Any] {
		return [
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
	}
	
	
	@objc func app(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		sendPluginResult(true, data: getApp())
	}
	func getApp() -> [String: Any] {
		return [
			"beta": Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? "true" : "false",
			"version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A",
			"bundle": Bundle.main.bundleIdentifier ?? "N/A"
		]
	}
	
	
	@objc func permissions(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		sendPluginResult(true, data: getPermissions())
	}
	func getPermissions() -> [String: String] {
		var permissionsDict: [String: String] = [:]
		
		// Location Permissions
		let locationManager = CLLocationManager()
		switch CLLocationManager.authorizationStatus() {
		case .authorizedAlways:
			permissionsDict["Location"] = "authorizedAlways"
		case .authorizedWhenInUse:
			permissionsDict["Location"] = "authorizedWhenInUse"
		default:
			permissionsDict["Location"] = "notAuthorized"
		}
		
		// Contacts Permission
		let contactStore = CNContactStore()
		switch CNContactStore.authorizationStatus(for: .contacts) {
		case .authorized:
			permissionsDict["Contacts"] = "authorized"
		default:
			permissionsDict["Contacts"] = "notAuthorized"
		}
		
		// Photos Permission
		switch PHPhotoLibrary.authorizationStatus() {
		case .authorized:
			permissionsDict["Photos"] = "authorized"
		default:
			permissionsDict["Photos"] = "notAuthorized"
		}
		
		// Calendar and Reminders Permissions
		let eventStore = EKEventStore()
		switch EKEventStore.authorizationStatus(for: .event) {
		case .authorized:
			permissionsDict["Calendar"] = "authorized"
		default:
			permissionsDict["Calendar"] = "notAuthorized"
		}
		switch EKEventStore.authorizationStatus(for: .reminder) {
		case .authorized:
			permissionsDict["Reminders"] = "authorized"
		default:
			permissionsDict["Reminders"] = "notAuthorized"
		}
		
		// Microphone Permission
		switch AVAudioSession.sharedInstance().recordPermission {
		case .granted:
			permissionsDict["Microphone"] = "authorized"
		default:
			permissionsDict["Microphone"] = "notAuthorized"
		}
		
		// Camera Permission
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			permissionsDict["Camera"] = "authorized"
		default:
			permissionsDict["Camera"] = "notAuthorized"
		}
		
		// Media Library Permission
		switch MPMediaLibrary.authorizationStatus() {
		case .authorized:
			permissionsDict["MediaLibrary"] = "authorized"
		default:
			permissionsDict["MediaLibrary"] = "notAuthorized"
		}
		
		return permissionsDict
	}
	
	
	@objc func network(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		sendPluginResult(true, data: getNetwork())
	}
	func getNetwork() -> [String: Any] {
		let networkInfo = CTTelephonyNetworkInfo()
		let carrier = networkInfo.subscriberCellularProvider
		
		return [
			"carrier": carrier?.carrierName ?? "N/A",
			"countryCode": carrier?.mobileCountryCode ?? "N/A"
		]
	}
	
	@objc func disk(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		sendPluginResult(true, data: getDisk())
	}
	func getDisk() -> [String: Any] {
		let fileManager = FileManager.default
		let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
		let systemAttributes = try? fileManager.attributesOfFileSystem(forPath: documentDirectory.path)
		let freeSpace = systemAttributes?[FileAttributeKey.systemFreeSize] as? NSNumber
		
		return [
			"freeSpace": freeSpace ?? "N/A"
		]
	}
	
	@objc func battery(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		sendPluginResult(true, data: getBattery())
	}
	func getBattery() -> [String: Any] {
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
		
		return [
			"batteryLevel": (UIDevice.current.batteryLevel * 100 * 100).rounded() / 100,
			"batteryState": batteryState
		]
	}
	
	@objc func jailbreak(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		sendPluginResult(true, data: getJailbreak())
	}
	func getJailbreak() -> [String: Any] {
		return [
			"isJailbroken": FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
		]
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
