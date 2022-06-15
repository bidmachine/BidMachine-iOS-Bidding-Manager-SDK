//
//  MediationLoggerProtocol.swift
//  BidMachineMediationModule
//
//  Created by Ilia Lozhkin on 11.06.2022.
//

import Foundation

@objc (BMMLogger) public
protocol MediationLogger {
    
    static var sharedLog: MediationLogger { get }
    
    func enableMediationLog(_ flag: Bool)
    
    func enableAdapterLog(_ flag: Bool)
    
    func enableNetworkLog(_ flag: Bool)
    
    func enableAdCallbackLog(_ flag: Bool)
    
}
