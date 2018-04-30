//
//  AppDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/22/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Crash reporting
    CrashManager.shared.appDidFinishLaunching()
    
    // Analytics
    AnalyticsManager.shared.appDidFinishLaunching()
    
    // Check if we have verified privacy
    if !Defaults.shared.hasOnboarded {
      let onboardingViewController = OnboardingViewController.newViewController(modalControllerDelegate: self)
      RootNavigationController.shared.viewControllers = [ onboardingViewController ]
    } else if !Defaults.shared.hasOnboardedPrivacy {
      let privacyViewController = self.getPrivacyOnbardingController(modalControllerDelegate: self)
      RootNavigationController.shared.viewControllers = [ privacyViewController ]
    } else if !PermissionManager.shared.isAccessAuthorized {
      let permissionsViewController = PermissionsViewController.newViewController(modalControllerDelegate: self)
      RootNavigationController.shared.viewControllers = [ permissionsViewController ]
    }
    
    // Set the initial app mode
    Defaults.shared.appMode = .myPlacemark
    FoodNearbyService.shared.configure()
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Stop listening for location updates
    CurrentLocationUpdatableService.shared.stopListening()
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Listen for location updates
    CurrentLocationUpdatableService.shared.startListening()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    MyDataManager.shared.saveMainContext()
  }
}

// MARK: - Delegates -

// MARK: - PrivacyNavigationDelegate

extension AppDelegate : PrivacyNavigationDelegate {}

// MARK: - ModalControllerDelegate

extension AppDelegate : ModalControllerDelegate {
  
  func dismissModalController(_ sender: UIViewController) {
    if !Defaults.shared.hasOnboarded {
      self.showOnboardingController()
    } else if !Defaults.shared.hasOnboardedPrivacy {
      self.showPrivacyController()
    } else if !PermissionManager.shared.isAccessAuthorized {
      self.showPermissionsController()
    } else {
      self.showMainController()
    }
  }
  
  func didAuthorizeAllPermissions() {
    self.showMainController()
  }
  
  private func showOnboardingController() {
    let onboardingViewController = OnboardingViewController.newViewController(modalControllerDelegate: self)
    onboardingViewController.navigationItem.hidesBackButton = true
    RootNavigationController.shared.pushViewController(onboardingViewController, animated: true)
  }
  
  private func showPermissionsController() {
    let privacyViewController = PermissionsViewController.newViewController(modalControllerDelegate: self)
    privacyViewController.navigationItem.hidesBackButton = true
    RootNavigationController.shared.pushViewController(privacyViewController, animated: true)
  }
  
  private func showPrivacyController() {
    let privacyViewController = self.getPrivacyOnbardingController(modalControllerDelegate: self)
    privacyViewController.navigationItem.hidesBackButton = true
    RootNavigationController.shared.pushViewController(privacyViewController, animated: true)
  }
  
  private func showMainController() {
    let mainViewController = MainViewController.newViewController()
    mainViewController.navigationItem.hidesBackButton = true
    RootNavigationController.shared.pushViewController(mainViewController, animated: true)
  }
}
