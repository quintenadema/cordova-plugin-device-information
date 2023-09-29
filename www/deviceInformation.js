var exec = require('cordova/exec');

var deviceInformation = {};

deviceInformation['device'] = async function() {
	return new Promise((resolve, reject) => {
		exec(resolve, reject, "DeviceInformation", "device", []);
	});
}
deviceInformation['app'] = async function() {
	return new Promise((resolve, reject) => {
		exec(resolve, reject, "DeviceInformation", "app", []);
	});
}
deviceInformation['network'] = async function() {
	return new Promise((resolve, reject) => {
		exec(resolve, reject, "DeviceInformation", "network", []);
	});
}
deviceInformation['disk'] = async function() {
	return new Promise((resolve, reject) => {
		exec(resolve, reject, "DeviceInformation", "disk", []);
	});
}
deviceInformation['battery'] = async function() {
	return new Promise((resolve, reject) => {
		exec(resolve, reject, "DeviceInformation", "battery", []);
	});
}
deviceInformation['jailbreak'] = async function() {
	return new Promise((resolve, reject) => {
		exec(resolve, reject, "DeviceInformation", "battery", []);
	});
}



deviceInformation['setCallback'] = async function(name, callback) {
	return new Promise((resolve, reject) => {
		exec(callback, reject, "DeviceInformation", "setCallback", [name]);
	});
}


module.exports = testflightDetector;
