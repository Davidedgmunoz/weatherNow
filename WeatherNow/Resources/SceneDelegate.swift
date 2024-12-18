//
//  SceneDelegate.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var cancellable: AnyCancellable?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // What I’m about to do is not ideal; do not try this at home!
        // Essentially, I’m going to pre-load the locations here.
        // We could create a splash screen to handle this in a more common and user-friendly way,
        // but to keep it simple and avoid over-engineering (probably more than I already am),
        // I will load it here and then display the screen.
        // Since it’s in memory, it likely won’t take more than a glimpse of a second.
        
        let models = Core.shared.models!
        let location = models.location
        
        // Lets ask notification permission upfront!
        models.notificationManager.requestAuthorization(completion: { _ in})
        cancellable = location.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink {
                guard location.state == .didSuccess else { return }
                let viewController = WeatherDetails.ViewController(
                    viewModel: WeatherDetails.DefaultViewModel(
                        model: models.location,
                        locationManager: models.locationManager,
                        calendarManager: models.calendarManager
                    )
                )
                let navigation = UINavigationController(rootViewController: viewController)
                self.window?.rootViewController = navigation
                self.window?.makeKeyAndVisible()
                self.cancellable?.cancel()
            }
        location.doSync()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

