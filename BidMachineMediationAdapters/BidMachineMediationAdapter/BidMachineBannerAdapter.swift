//
//  BidMachineBannerAdapter.swift
//  BidMachineMediationAdapter
//
//  Created by Ilia Lozhkin on 10.05.2022.
//

import UIKit
import BidMachine
import BidMachineMediationModule

class BidMachineBannerAdapter: NSObject, MediationAdapterProtocol {
    
    weak var loadingDelegate: MediationAdapterLoadingDelegate?
    
    weak var displayDelegate: MediationAdapterDisplayDelegate?
    
    var adapterParams: MediationAdapterParamsProtocol
    
    var adapterPrice: Double {
        return banner.adObject.flatMap { $0.auctionInfo.price }.flatMap { $0.doubleValue } ?? 0
    }
    
    var adapterReady: Bool {
        return banner.isLoaded
    }
    
    private lazy var banner: BDMBannerView = {
        let banner = BDMBannerView()
        banner.delegate = self
        banner.producerDelegate = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        return banner
    }()
    
    required init(_ params: MediationParams) {
        adapterParams = BidMachineAdapterParams(params)
    }
    
    func load() {
        let request = BDMBannerRequest()
        if let params = adapterParams as? BidMachineAdapterParams {
            request.customParameters = params.config.flatMap { $0.targetingParams }
            request.adSize = adapterParams.size.bannerSize()
        }
        
        if adapterParams.price > 0 {
            request.priceFloors = [adapterParams.price].compactMap {
                let floor = BDMPriceFloor()
                floor.id = "mediation_price"
                floor.value = NSDecimalNumber(value: $0)
                return floor
            }
        }
        self.banner.populate(with: request)
    }
    
    func present() {
        guard let view = adapterParams.container, let controller = adapterParams.controller else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("BidMachine banner"))}
            return;
        }
        
        banner.rootViewController = controller
        
        view.addSubview(banner)
        [banner.topAnchor.constraint(equalTo: view.topAnchor),
         banner.leftAnchor.constraint(equalTo: view.leftAnchor),
         banner.rightAnchor.constraint(equalTo: view.rightAnchor),
         banner.bottomAnchor.constraint(equalTo: view.bottomAnchor)].forEach { $0.isActive = true }
    }
}

extension BidMachineBannerAdapter: BDMBannerDelegate {
    
    func bannerViewReady(toPresent bannerView: BDMBannerView) {
        self.loadingDelegate.flatMap { $0.didLoad(self) }
    }
    
    func bannerView(_ bannerView: BDMBannerView, failedWithError error: Error) {
        self.loadingDelegate.flatMap { $0.failLoad(self, error) }
    }
    
    func bannerViewRecieveUserInteraction(_ bannerView: BDMBannerView) {
        self.displayDelegate.flatMap { $0.didTrackInteraction(self) }
    }
    
    func bannerViewWillPresentScreen(_ bannerView: BDMBannerView) {
        self.displayDelegate.flatMap { $0.willPresentScreen(self) }
    }
    
    func bannerViewDidDismissScreen(_ bannerView: BDMBannerView) {
        self.displayDelegate.flatMap { $0.didDismissScreen(self) }
    }
    
    func bannerViewDidExpire(_ bannerView: BDMBannerView) {
        self.displayDelegate.flatMap { $0.didTrackExpired(self) }
    }
}

extension BidMachineBannerAdapter: BDMAdEventProducerDelegate {
    
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        self.displayDelegate.flatMap { $0.didTrackImpression(self) }
    }
    
    func didProduceUserAction(_ producer: BDMAdEventProducer) {
        
    }
}

private extension MediationSize {
    
    func bannerSize() -> BDMBannerAdSize {
        switch self {
        case .unowned: return .sizeUnknown
        case .banner: return .size320x50
        case .mrec: return .size300x250
        case .leaderboard: return .size728x90
        @unknown default:
            return .sizeUnknown
        }
    }
    
}
