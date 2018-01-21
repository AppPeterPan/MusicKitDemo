//
//  AuthorizeTableViewController.swift
//  MusicKitDemo
//
//  Created by SHIH-YING PAN on 14/01/2018.
//  Copyright © 2018 SHIH-YING PAN. All rights reserved.
//

import UIKit
import StoreKit

class AuthorizeTableViewController: UITableViewController {

    @IBOutlet weak var addToLibrarySwitch: UISwitch!
    
    @IBOutlet weak var playbackSwitch: UISwitch!
    @IBOutlet weak var subscriptionEligibleSwitch: UISwitch!
    
    @IBOutlet weak var authorizationStatusLabel: UILabel!
    
    @IBOutlet weak var userTokenLabel: UILabel!
    @IBOutlet weak var developerTokenLabel: UILabel!
    
    @objc func handleAuthorizationManagerAuthorizationDidUpdateNotification() {
        DispatchQueue.main.async {
            
            self.updateAuthorizationStatusLabel()
            if SKCloudServiceController.authorizationStatus() == .authorized {
                AuthorizationManager.shared.requestCloudServiceCapabilities()
                
            }
            
        }
        
        
    }
    
    func updateCloudServiceCapabilitySwitches() {
         if let cloudServiceCapabilities = AuthorizationManager.shared.cloudServiceCapabilities {
            
            subscriptionEligibleSwitch.isOn = cloudServiceCapabilities.contains(.musicCatalogSubscriptionEligible)
            playbackSwitch.isOn = cloudServiceCapabilities.contains(.musicCatalogPlayback)
            addToLibrarySwitch.isOn = cloudServiceCapabilities.contains(.addToCloudMusicLibrary)
            
        }
    }
    
    @objc func handleCloudServiceDidUpdateNotification() {
        
        
        if let cloudServiceCapabilities = AuthorizationManager.shared.cloudServiceCapabilities {
            
            DispatchQueue.main.async {
                self.updateCloudServiceCapabilitySwitches()
            }
            if cloudServiceCapabilities.contains(.musicCatalogPlayback) {
                AuthorizationManager.shared.requestUserToken()
                AuthorizationManager.shared.requestStorefrontCountryCode()
            } else {
                if cloudServiceCapabilities.contains(.musicCatalogSubscriptionEligible) {
                    DispatchQueue.main.async {
                        self.presentCloudServiceSetup()
                        
                    }
                }
            }
                
        }
        
       
    }
    
    @objc func handleUserTokenDidUpdateNotification() {
        DispatchQueue.main.async {
            self.userTokenLabel.text = AuthorizationManager.shared.userToken
        }
    }
    
    func updateAuthorizationStatusLabel() {
        switch SKCloudServiceController.authorizationStatus() {
        case .notDetermined:
            authorizationStatusLabel.text = "Not Determined"
        case .denied:
            authorizationStatusLabel.text = "Denied"
        case .restricted:
            authorizationStatusLabel.text = "Restricted"
        case .authorized:
            authorizationStatusLabel.text = "Authorized"
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        updateAuthorizationStatusLabel()
        userTokenLabel.text = AuthorizationManager.shared.userToken
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAuthorizationManagerAuthorizationDidUpdateNotification), name: .authorizationDidUpdateNotification, object: nil)
        

        NotificationCenter.default.addObserver(self, selector: #selector(handleUserTokenDidUpdateNotification), name: .userTokenDidUpdateNotification, object: nil)
        


        NotificationCenter.default.addObserver(self, selector: #selector(handleCloudServiceDidUpdateNotification), name: .cloudServiceDidUpdateNotification, object: nil)
        

        
        AppleMusicManager.shared.fetchDeveloperTokenFromNetwork {
            
            DispatchQueue.main.async {
                self.developerTokenLabel.text = AppleMusicManager.shared.developerToken
            }
            
            guard AppleMusicManager.shared.developerToken != "" else {
                return
            }
            
            if SKCloudServiceController.authorizationStatus() == .authorized {
                NotificationCenter.default.post(name: .authorizationDidUpdateNotification, object: nil)
            
                
            } else {
                AuthorizationManager.shared.requestAuthorization()
                
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentCloudServiceSetup() {
        
       
        /*
         If the current `SKCloudServiceCapability` includes `.musicCatalogSubscriptionEligible`, this means that the currently signed in iTunes Store
         account is elgible for an Apple Music Trial Subscription.  To provide the user with an option to sign up for a free trial, your application
         can present the `SKCloudServiceSetupViewController` as demonstrated below.
         */
        
        let cloudServiceSetupViewController = SKCloudServiceSetupViewController()
        cloudServiceSetupViewController.delegate = self
        cloudServiceSetupViewController.load(options: [.action: SKCloudServiceSetupAction.subscribe]) { [weak self] (result, error) in
            guard error == nil else {
                fatalError("An Error occurred: \(error!.localizedDescription)")
            }
            
            if result {
                self?.present(cloudServiceSetupViewController, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Table view data source

    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AuthorizeTableViewController: SKCloudServiceSetupViewControllerDelegate {
    func cloudServiceSetupViewControllerDidDismiss(_ cloudServiceSetupViewController: SKCloudServiceSetupViewController) {
        if SKCloudServiceController.authorizationStatus() == .authorized {
            NotificationCenter.default.post(name: .authorizationDidUpdateNotification, object: nil)
            
        }
    }
}

