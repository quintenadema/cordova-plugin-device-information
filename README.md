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
	"device": [
		"model": "iPhone",
		"systemVersion": "17.0.2",
		"name": "iPhone"
	],
	"locale": [
		"locale": "en_NL",
		"preferredLanguages": [
			"nl-NL",
			"en-NL"
		]
	],
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
	"version": "3.0.13",
	"beta": true,
	"bundle": "com.ademagroup.moofer"
}
```


### Get permissions
Usage:
```
const permissions = await deviceInformation.permissions();
console.log(permissions);
```

Example response:
```
{
	"location": "authorizedAlways", // iOS only
	"location": "authorizedWhenInUse", // iOS only
	"location": "authorizedFine", // Android only
	"location": "authorizedCoarse", // Android only

	"backgroundLocation": "authorized", // Android only
	
	"camera": "notAuthorized",
	"contacts": "notAuthorized",
	"microphone": "notAuthorized",
	"photos": "notAuthorized",
	
	"calendar": "notAuthorized",
	"reminders": "notAuthorized" // iOS only
	
	"mediaLibrary": "notAuthorized", // iOS only
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
	"carrier": "--",
	"countryCode": "65535"
}
```

### Get disk information
Usage:
```
const disk = await deviceInformation.disk();
console.log(disk);
```

Example response:
```
{
	"freeSpace": 59762274304 // bytes
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
Usage:
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



### Set callback
Usage:
```
deviceInformation.setCallback('onBattery', function(battery) {
	console.log(battery);
});
```