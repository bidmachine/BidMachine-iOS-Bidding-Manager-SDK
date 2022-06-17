//
//  BidMachineNetwork.swift
//  BidMachineMediationAdapter
//
//  Created by Ilia Lozhkin on 10.05.2022.
//

import BidMachine
import BidMachineMediationModule

class BidMachineNework: MediationNetworkProtocol {
    
    var networkName: String = NetworkDefines.bidmachine.name
    
    weak var delegate: MediationNetworkDelegate?
    
    func initializeNetwork(_ params: MediationParams) {
        if BDMSdk.shared().isInitialized {
            delegate.flatMap { $0.didInitialized(self) }
            return
        }
        
        guard let config = BidMachineNeworkParams(params).config else {
            delegate.flatMap { $0.didFailInitialized(self, MediationError.initializeError("BidMachine initialization params is null"))}
            return
        }
        
        let sdkConfig = BDMSdkConfiguration()
        let targeting = BDMTargeting()
        targeting.storeId = config.storeId
        
        sdkConfig.testMode = config.testMode.flatMap{ $0 as NSString }.flatMap { $0.boolValue } ?? false
        sdkConfig.targeting = targeting
        
        BDMSdk.shared().startSession(withSellerID: config.sourceId, configuration: sdkConfig) { [weak self] in
            self.flatMap { $0.delegate?.didInitialized($0) }
        }
    }
    
    func adapter(_ type: MediationType, _ placement: MediationPlacement) -> MediationAdapterProtocol.Type? {
        return placement.adapter()
    }
    
    required init() {
        
    }
}

extension MediationPlacement {
    func adapter() -> MediationAdapterProtocol.Type? {
        switch self {
        case .banner: return BidMachineBannerAdapter.self
        case .interstitial: return BidMachineInterstitialAdapter.self
        case .rewarded: return BidMachineRewardedAdapter.self
        default: return nil
        }
    }
}

