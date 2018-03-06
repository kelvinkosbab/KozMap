//
//  AnalyticsManager.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/5/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Firebase

/*
 * Analtyics Manager is responsible for handling any analytics tools
 *
 * Currently Includes:
 *  - Firebase
 */

class AnalyticsManager : NSObject {
  
  // MARK: - Singleton
  
  static let shared: AnalyticsManager = AnalyticsManager()
  
  override init() { super.init() }
  
  // MARK: - App Launch
  
  func appDidFinishLaunching() {
    
    // Firebase
    self.setupFirebase()
  }
  
  // MARK: - Firebase
  
  private func setupFirebase() {
    let firebasePlistFileName = "GoogleService-Info"
    let firebaseOptions = FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: firebasePlistFileName, ofType: "plist")!)
    FirebaseApp.configure(options: firebaseOptions!)
  }
  
  // MARK: - Screen Views
  
  func didView(_ screen: AnalyticsScreen, screenClass: String? = nil) {
    Analytics.setScreenName(screen.name, screenClass: screenClass)
  }
  
  // MARK - Event
  
  func didEvent(_ event: AnalyticsEvent) {
    Analytics.logEvent(event.name, parameters: event.parameters)
  }
  
  // MARK - User Properties
  
  func sendBaseMetrics() {
    // Set the User Properties
    for item in AnalyticsItem.all {
      Analytics.setUserProperty(item.value, forName: item.rawValue)
    }
  }
}
