//
//  BidOperation.swift
//  BidMachineMediationModule
//
//  Created by Ilia Lozhkin on 09.05.2022.
//

import Foundation

protocol BidOperation {
    
    func adaptorWrappers() -> [MediationAdapterWrapper]
    
}
