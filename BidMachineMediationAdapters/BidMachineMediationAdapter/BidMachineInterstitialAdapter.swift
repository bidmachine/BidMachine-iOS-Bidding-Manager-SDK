//
//  BidMachineInterstitialAdapter.swift
//  BidMachineMediationAdapter
//
//  Created by Ilia Lozhkin on 10.05.2022.
//

import UIKit
import BidMachine
import BidMachineMediationModule

class BidMachineInterstitialAdapter: NSObject, MediationAdapterProtocol {
    
    weak var loadingDelegate: MediationAdapterLoadingDelegate?
    
    weak var displayDelegate: MediationAdapterDisplayDelegate?
    
    var adapterParams: MediationAdapterParamsProtocol
    
    var adapterPrice: Double {
        return CPM
    }
    
    var adapterReady: Bool {
        return  interstitial.isLoaded
    }
    
    private var CPM: Double = 0
    
    private lazy var interstitial: BDMInterstitial = {
        let interstitial = BDMInterstitial()
        interstitial.delegate = self
        interstitial.producerDelegate = self
        return interstitial
    }()
    
    required init(_ params: MediationParams) {
        adapterParams = BidMachineAdapterParams(params)
    }
    
    func load() {
        let request = BDMInterstitialRequest()
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
        self.interstitial.populate(with: request)
    }
    
    func present() {
        guard let controller = adapterParams.controller else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("BidMachine interstitial"))}
            return;
        }
        
        interstitial.present(fromRootViewController: controller)
    }
}

extension BidMachineInterstitialAdapter: BDMInterstitialDelegate {
    
    func interstitialReady(toPresent interstitial: BDMInterstitial) {
        self.CPM = interstitial.adObject.flatMap { $0.auctionInfo.price }.flatMap { $0.doubleValue } ?? 0
        self.loadingDelegate.flatMap { $0.didLoad(self) }
    }
    
    func interstitial(_ interstitial: BDMInterstitial, failedWithError error: Error) {
        self.loadingDelegate.flatMap { $0.failLoad(self, error) }
    }
    
    func interstitial(_ interstitial: BDMInterstitial, failedToPresentWithError error: Error) {
        self.displayDelegate.flatMap { $0.didFailPresent(self, error) }
    }
    
    func interstitialWillPresent(_ interstitial: BDMInterstitial) {
        self.displayDelegate.flatMap { $0.willPresentScreen(self) }
    }
    
    func interstitialDidDismiss(_ interstitial: BDMInterstitial) {
        self.displayDelegate.flatMap { $0.didDismissScreen(self) }
    }
    
    func interstitialRecieveUserInteraction(_ interstitial: BDMInterstitial) {
        self.displayDelegate.flatMap { $0.didTrackInteraction(self) }
    }
    
    func interstitialDidExpire(_ interstitial: BDMInterstitial) {
        self.displayDelegate.flatMap { $0.didTrackExpired(self) }
    }
}

extension BidMachineInterstitialAdapter: BDMAdEventProducerDelegate {
    
    func didProduceUserAction(_ producer: BDMAdEventProducer) {
        
    }
    
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        self.displayDelegate.flatMap { $0.didTrackImpression(self) }
    }
}
