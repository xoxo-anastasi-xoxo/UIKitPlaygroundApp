//
//  AppDelegate.swift
//  UIKitPlaygroundApp
//
//  Created by Anastasia Kazantseva on 30.03.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow()

        window.rootViewController = OperationBasicsController()
        window.makeKeyAndVisible()

        self.window = window

        return true
    }

}

