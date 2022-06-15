//
//  Rewarded.swift
//  BidMachineSample
//
//  Created by Ilia Lozhkin on 15.06.2022.
//

import UIKit
import BidMachineMediationModule

class Rewarded: BaseController {
    
    private var rewarded: BidMachineMediationModule.Rewarded?
    
    override func loadButtonAction(_ sender: UIButton) {
        super.loadButtonAction(sender)
        
        let rewarded = BidMachineMediationModule.Rewarded()
        rewarded.delegate = self
        rewarded.controller = self
        rewarded.loadAd {
            $0.appendTimeout(20)
            $0.prebidConfig.appendTimeout(5)
                .appendAdUnit(NetworDefines.bidmachine.name, [:])
                .appendAdUnit(NetworDefines.applovin.name, ["unitId":"YOUR_ID"])
            
            $0.postbidConfig.appendTimeout(5)
                .appendAdUnit(NetworDefines.bidmachine.name, [:])
                .appendAdUnit(NetworDefines.admob.name, ["lineItems" : [
                    ["price" : 10, "unitId" : "ca-app-pub-3940256099942544/1712485313"],
                    ["price" : 9, "unitId" : "ca-app-pub-3940256099942544/1712485313"],
                    ["price" : 8, "unitId" : "ca-app-pub-3940256099942544/1712485313"],
                    ["price" : 7, "unitId" : "ca-app-pub-3940256099942544/1712485313"],
                    ["price" : 6, "unitId" : "ca-app-pub-3940256099942544/1712485313"],
                    ["price" : 5, "unitId" : "ca-app-pub-3940256099942544/1712485313"]
                ]])
        }
        
        self.rewarded = rewarded
    }
    
    override func showButtonAction(_ sender: UIButton) {
        super.showButtonAction(sender)
        
        self.rewarded?.present {
            
        }
    }
    
}

extension Rewarded: DisplayAdDelegate {
    
    func adDidLoad(_ ad: DisplayAd) {
        switchState(.ready)
    }
    
    func adFailToLoad(_ ad: DisplayAd, with error: Error) {
        switchState(.idle)
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

