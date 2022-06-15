//
//  BidMachineRewardedAdapter.swift
//  BidMachineMediationAdapter
//
//  Created by Ilia Lozhkin on 10.05.2022.
//

import UIKit
import BidMachine
import BidMachineMediationModule

class BidMachineRewardedAdapter: NSObject, MediationAdapterProtocol {
    
    weak var loadingDelegate: MediationAdapterLoadingDelegate?
    
    weak var displayDelegate: MediationAdapterDisplayDelegate?
    
    var adapterParams: MediationAdapterParamsProtocol
    
    var adapterPrice: Double {
        return CPM
    }
    
    var adapterReady: Bool {
        return  rewarded.isLoaded
    }
    
    private var CPM: Double = 0
    
    private lazy var rewarded: BDMRewarded = {
        let rewarded = BDMRewarded()
        rewarded.delegate = self
        rewarded.producerDelegate = self
        return rewarded
    }()
    
    required init(_ params: MediationParams) {
        adapterParams = BidMachineAdapterParams(params)
    }
    
    func load() {
        let request = BDMRewardedRequest()
        if let params = adapterParams as? BidMachineAdapterParams {
            request.customParameters = params.config.flatMap { $0.targetingParams }
        }
        
        if adapterParams.price > 0 {
            request.priceFloors = [adapterParams.price].compactMap {
                let floor = BDMPriceFloor()
                floor.id = "mediation_price"
                floor.value = NSDecimalNumber(value: $0)
                return floor
            }
        }
        self.rewarded.populate(with: request)
    }
    
    func present() {
        guard let controller = adapterParams.controller else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("BidMachine rewarded"))}
            return;
        }
        
        rewarded.present(fromRootViewController: controller)
    }
}

extension BidMachineRewardedAdapter: BDMRewardedDelegate {
    
    func rewardedReady(toPresent rewarded: BDMRewarded) {
        self.CPM = rewarded.adObject.flatMap { $0.auctionInfo.price }.flatMap { $0.doubleValue } ?? 0
        self.loadingDelegate.flatMap { $0.didLoad(self) }
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedWithError error: Error) {
        self.loadingDelegate.flatMap { $0.failLoad(self, error) }
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedToPresentWithError error: Error) {
        self.displayDelegate.flatMap { $0.didFailPresent(self, error) }
    }
    
    func rewardedWillPresent(_ rewarded: BDMRewarded) {
        self.displayDelegate.flatMap { $0.willPresentScreen(self) }
    }
    
    func rewardedDidDismiss(_ rewarded: BDMRewarded) {
        self.displayDelegate.flatMap { $0.didDismissScreen(self) }
    }
    
    func rewardedRecieveUserInteraction(_ rewarded: BDMRewarded) {
        self.displayDelegate.flatMap { $0.didTrackInteraction(self) }
    }
    
    func rewardedFinishRewardAction(_ rewarded: BDMRewarded) {
        self.displayDelegate.flatMap { $0.didTrackReward(self) }
    }
    
    func rewardedDidExpire(_ rewarded: BDMRewarded) {
        self.displayDelegate.flatMap { $0.didTrackExpired(self) }
    }
}

extension BidMachineRewardedAdapter: BDMAdEventProducerDelegate {
    
    func didProduceUserAction(_ producer: BDMAdEventProducer) {
        
    }
    
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        self.displayDelegate.flatMap { $0.didTrackImpression(self) }
    }
}
