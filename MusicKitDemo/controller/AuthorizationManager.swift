//
//  AuthorizationManager.swift
//  MusicKitDemo
//
//  Created by SHIH-YING PAN on 20/01/2018.
//  Copyright © 2018 SHIH-YING PAN. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

extension Notification.Name {
    static let authorizationDidUpdateNotification = Notification.Name("authorizationDidUpdateNotification")
    static let userTokenDidUpdateNotification = Notification.Name("userTokenDidUpdateNotification")
    static let cloudServiceDidUpdateNotification = Notification.Name("cloudServiceDidUpdateNotification")
    
}

class AuthorizationManager {
    
    static let shared = AuthorizationManager()
    
    let cloudServiceController = SKCloudServiceController()
    var cloudServiceCapabilities: SKCloudServiceCapability?
    var cloudServiceStorefrontCountryCode = ""

    var userToken = "" {
        didSet {
            NotificationCenter.default.post(name: .userTokenDidUpdateNotification, object: nil)
        }
    }
    
   
    
    // MARK: `SKCloudServiceController` Related Methods
    
    
    
    
    func requestUserToken() {
        
        cloudServiceController.requestUserToken(forDeveloperToken: AppleMusicManager.shared.developerToken, completionHandler: { [weak self] (token, error) in
            guard error == nil else {
                print("An error occurred when requesting user token: \(error!.localizedDescription)")
                return
            }
            guard let token = token else {
                print("Unexpected value from SKCloudServiceController for user token.")
                return
            }
            self?.userToken = token
            
            
        })
        
        
    }
    
    func requestCloudServiceCapabilities() {
        cloudServiceController.requestCapabilities(completionHandler: { [weak self] (capabilities, error) in
            
            
            guard error == nil else {
                fatalError("An error occurred when requesting capabilities: \(error!.localizedDescription)")
            }
            self?.cloudServiceCapabilities = capabilities
            print(capabilities)
            if capabilities.contains(.addToCloudMusicLibrary) {
                // The application can add items to the iCloud Music Library.
                print("addToCloudMusicLibrary")
            }
            
            if capabilities.contains(.musicCatalogPlayback) {
                // The application can playback items from the Apple Music catalog.
                print("musicCatalogPlayback")
                
            }
            
            if capabilities.contains(.musicCatalogSubscriptionEligible) {
                // The iTunes Store account is currently elgible for and Apple Music Subscription trial.
                print("musicCatalogSubscriptionEligible")
                
            }
            
            NotificationCenter.default.post(name: .cloudServiceDidUpdateNotification, object: nil)
        })
    }
    
    func requestAuthorization() {
        SKCloudServiceController.requestAuthorization { (status) in
            
            NotificationCenter.default.post(name: .authorizationDidUpdateNotification, object: nil)
            
        }
    }
    
    func requestStorefrontCountryCode() {
        cloudServiceController.requestStorefrontCountryCode { (countryCode, error) in
            guard error == nil else {
                print("An error occurred when requesting storefront country code: \(error!.localizedDescription)")
                return
            }
            
            guard let countryCode = countryCode else {
                print("Unexpected value from SKCloudServiceController for storefront country code.")
                return
            }
            
            self.cloudServiceStorefrontCountryCode = countryCode
        }
    }
    
}
