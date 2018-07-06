//
//  AppDelegate.swift
//  Peoject_CoreImage
//
//  Created by iOS Development on 6/25/18.
//  Copyright © 2018 Genisys. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = LiveCameraFilterVC()
        return true
    }

    


}

