//
//  AppDelegate.swift
//  BidMachineSample
//
//  Created by Ilia Lozhkin on 15.06.2022.
//

import UIKit
import BidMachineMediationModule

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logging.sharedLog.enableMediationLog(true)
        Logging.sharedLog.enableAdapterLog(true)
        Logging.sharedLog.enableNetworkLog(true)
        Logging.sharedLog.enableAdCallbackLog(true)
        
        NetworkRegistration.shared.registerNetwork(NetworDefines.applovin.klass, [:])
        NetworkRegistration.shared.registerNetwork(NetworDefines.admob.klass, [:])
        NetworkRegistration.shared.registerNetwork(NetworDefines.bidmachine.klass, ["sourceId": "1", "testMode" : "false"])

        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

