//
//  MyPlaylistTableViewController.swift
//  MusicKitDemo
//
//  Created by SHIH-YING PAN on 14/01/2018.
//  Copyright © 2018 SHIH-YING PAN. All rights reserved.
//

import UIKit
import MediaPlayer

class MyPlaylistTableViewController: UITableViewController {

    var playlists = [MPMediaPlaylist]()
   
    func showResultAlert(result: Bool) {
        let title: String
        if result {
            title = "成功"
        } else {
            title = "失敗"
        }
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if result {
                self.playlists =  AppleMusicManager.shared.getPlaylists()
                self.tableView.reloadData()
            }
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func createPlaylist(_ sender: Any) {
        
        let alertController = UIAlertController(title: "create playlist", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "name"
        }
        alertController.addTextField { (textfield) in
            textfield.placeholder = "description"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let name = alertController.textFields?[0].text, let description = alertController.textFields?[1].text {
                AppleMusicManager.shared.createPlaylist(name: name, description: description, completion: { (result) in
                    self.showResultAlert(result: result)
                    
                })
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        playlists =  AppleMusicManager.shared.getPlaylists()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

  

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playlists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)

        // Configure the cell...
        let playlist = playlists[indexPath.row]
        cell.textLabel?.text = playlist.name
        
        return cell
    }
    

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
