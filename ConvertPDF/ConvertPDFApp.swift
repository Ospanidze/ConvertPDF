//
//  ConvertPDFApp.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 17.10.2025.
//

import SwiftUI

@main
struct ConvertPDFApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            Color.clear
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    class SingleTouchWindow: UIWindow {
        override init(windowScene: UIWindowScene) {
            super.init(windowScene: windowScene)
            self.isMultipleTouchEnabled = false
            self.isExclusiveTouch = true
        }
        required init?(coder: NSCoder) { nil }
    }
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = SingleTouchWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light
        window?.rootViewController = UIHostingController(rootView: RouterView(ContentView()))
        window?.makeKeyAndVisible()
    }
}
