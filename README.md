# Cordova Device Information
Cordova plugin to check all sorts of device information

## Installation
Simply run
```
cordova plugin add https://github.com/quintenadema/cordova-plugin-device-information
```

## Usage
### Get device information
Usage:
```
const device = await deviceInformation.device();
console.log(device);
```

Example response:
```
{
	"locale": [
		"locale": "",
		"preferredLanguages": [
			"",
			""
		]
	],
	"device": [
		"model": "",
		"systemVersion": "",
		"name": ""
	]
}
```


### Get app information
Usage:
```
const app = await deviceInformation.app();
console.log(app);
```

Example response:
```
{
}
```

### Get network information
Usage:
```
const network = await deviceInformation.network();
console.log(network);
```

Example response:
```
{

}
```

### Get battery information
Usage:
```
const battery = await deviceInformation.battery();
console.log(battery);
```

Example response:
```
{
	"batteryCharge": 60,
	"batteryState": "charging"
}
```

### Get jailbreak information
```
const jailbreak = await deviceInformation.jailbreak();
console.log(jailbreak);
```

Example response:
```
{
	"isJailbroken": true
}
```