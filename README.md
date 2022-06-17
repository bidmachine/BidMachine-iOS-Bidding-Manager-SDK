![BidMachine iOS](https://appodeal-ios.s3-us-west-1.amazonaws.com/docs/bidmachine.png)
# BidMachine-iOS-Mediation-SDK

[<img src="https://img.shields.io/badge/SDK%20Version-1.9.4-brightgreen">](https://docs.bidmachine.io/docs/in-house-mediation-1)
[<img src="https://img.shields.io/badge/Applovin%20MAX%20Version-11.3.3-blue">](https://dash.applovin.com/documentation/mediation/ios/getting-started/integration)
[<img src="https://img.shields.io/badge/AdMob%20Version-9.5.0-blue">](https://developers.google.com/admob/ios/quick-start)

* [Logging](#logging)
* [Initialization](#initialization)
* [Loading](#loading)
* [Presenting](#presenting)
* [Adaptors](#Adaptors)
    + [BidMachine](#bidmachine)
    + [Applovin](#applovin)
    + [AdMob](#admob)

## Logging

SDK supports logging of individual sections of code

``` swift

 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Logging.sharedLog.enableMediationLog(true)
        Logging.sharedLog.enableAdapterLog(true)
        Logging.sharedLog.enableNetworkLog(true)
        Logging.sharedLog.enableAdCallbackLog(true)

        return true
    }

```

## Initialization

Before using the SDK you must initialize and register the ad networks

``` swift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.startNetworksSession { [weak self] in
            self.flatMap { $0.registerNetwork() }
        }

        return true
    }

func registerNetwork() {
        NetworkRegistration.shared.registerNetwork(NetworkDefines.applovin.klass, [:])
        NetworkRegistration.shared.registerNetwork(NetworkDefines.admob.klass, [:])
        NetworkRegistration.shared.registerNetwork(NetworkDefines.bidmachine.klass, [:])
    }

func startNetworksSession(_ completion: @escaping () -> Void) {

        let sdkConfig = BDMSdkConfiguration()
        let targeting = BDMTargeting()
        
        targeting.storeId = "1111"
        sdkConfig.testMode = false
        sdkConfig.targeting = targeting
        
        BDMSdk.shared().startSession(withSellerID: "1", configuration: sdkConfig) {
            ALSdk.shared()?.mediationProvider = ALMediationProviderMAX
            ALSdk.shared()?.initializeSdk()
            
            GADMobileAds.sharedInstance().start { _ in
                completion()
            }
        }
    }
```

## Loading

Loading for all types of ads is the same

You can set the configuration for loading in the loadAd method

> **_NOTE:_**  .controller - is required property to load ad

``` swift
interstitial.delegate = self
interstitial.controller = self
interstitial.loadAd {
            $0.appendTimeout(20) 
                // .appendAdSize(.banner) // if needed (mrec, banner, leaderboard size set)
                // .appendPriceFloor(30)  // if needed (set your custom price)
            $0.prebidConfig.appendTimeout(5)
                .appendAdUnit(NetworkDefines.bidmachine.name, [:])
                .appendAdUnit(NetworkDefines.applovin.name, ["unitId":"YOUR_ID"])
            
            $0.postbidConfig.appendTimeout(5)
                .appendAdUnit(NetworkDefines.bidmachine.name, [:])
                .appendAdUnit(NetworkDefines.admob.name, ["lineItems" : [
                    ["price" : 10, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_10"],
                    ["price" : 9, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_9"],
                    ["price" : 8, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_8"],
                    ["price" : 7, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_7"],
                    ["price" : 6, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_6"],
                    ["price" : 5, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_5"]
                ]])
        }

```

Delegate:

``` swift

extension Interstitial: DisplayAdDelegate {
    
    func adDidLoad(_ ad: DisplayAd) {
        
    }
    
    func adFailToLoad(_ ad: DisplayAd, with error: Error) {
        
    }
    
    func adFailToPresent(_ ad: DisplayAd, with error: Error) {
        
    }
    
    func adWillPresentScreen(_ ad: DisplayAd) {
        
    }
    
    func adDidDismissScreen(_ ad: DisplayAd) {
        
    }
    
    func adRecieveUserAction(_ ad: DisplayAd) {
        
    }
    
    func adDidTrackImpression(_ ad: DisplayAd) {
        
    }
    
    func adDidExpired(_ ad: DisplayAd) {
        
    }
}

```

## Presenting

**Banner** and **AutorefreshBanner** automatically show ads when they are in a hierarchy.
For other types, you must call the display manually

**AutorefreshBanner**

To prevent the banner from updating, it must be hidden.

``` swift

banner.hideAd()

```


**Interstitial**

``` swift

self.interstitial?.present()

```

**Rewarded**

``` swift

self.rewarded?.present { 
	// reward callback
}

```

## Adaptors

#### Adaptor params:

|            | Class                          | Name                          |
|------------|--------------------------------|-------------------------------|
| Applovin   | NetworkDefines.applovin.klass   | NetworkDefines.applovin.name   |
| BidMachine | NetworkDefines.bidmachine.klass | NetworkDefines.bidmachine.name |
| AdMob      | NetworkDefines.admob.klass      | NetworkDefines.admob.name      |

#### Adapter bidding support: 

|            | Prebid | Postbid |
|------------|--------|---------|
| BidMachine |    +   |    +    |
| Applovin   |    +   |    -    |
| AdMob      |    -   |    +    |

### BidMachine

Initialized params :

|          | Type   | Example  |
|----------|--------|----------|
| sourceId | String | "1"      |
| testMode | String | "true"   |
| storeId  | String | "123456" |

Bidding params :

|                 | Type            | Example           |
|-----------------|-----------------|-------------------|
| targetingParams | [String:String] | ["key" : "value"] |

### Applovin

Initialized params :

Parameters for initialization are not required

Bidding params :

|        | Type   | Example |
|--------|--------|---------|
| unitId | String | "1-567" |

### AdMob

Initialized params :

Parameters for initialization are not required

Bidding params :

Each ad unit is configured in the [AdMob dashboard](https://apps.admob.com).
For each ad unit, you need to set up an eCPM floor

|           | Type                | Attachment | Type   | Example                                 |
|-----------|---------------------|------------|--------|-----------------------------------------|
| lineItems | [[String : String]] |            |        | [["price" : "1.0", "unitId" : "1-567"]] |
|           |                     | price      | String | "1.0"                                   |
|           |                     | unitId     | String | "1-567"                                 |

