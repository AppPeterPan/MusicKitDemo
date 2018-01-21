//
//  SongTableViewController.swift
//  MusicKitDemo
//
//  Created by SHIH-YING PAN on 15/01/2018.
//  Copyright © 2018 SHIH-YING PAN. All rights reserved.
//

import UIKit
import MediaPlayer

class MediaItemTableViewController: UITableViewController {
    
    struct PropertyKeys {
        static let showMediaItemSegue = "showMediaItemSegue"
    }
    
    var hasMoreData = true
    let musicPlayerController = MPMusicPlayerController.systemMusicPlayer

    var mediaItems = [MediaItem]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName: MediaItemTableViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: MediaItemTableViewCell.cellIdentifier)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: PropertyKeys.showMediaItemSegue, sender: nil)
    }

    
    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mediaItems.count
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MediaItemTableViewCell.cellIdentifier, for: indexPath) as? MediaItemTableViewCell else {
            return UITableViewCell()
        }
        
        
        // Configure the cell...
        let mediaItem = mediaItems[indexPath.row]
        cell.mediaItem = mediaItem
        cell.delegate = self
        cell.nameLabel.text = mediaItem.name
        cell.singerLabel.text = mediaItem.artistName
        cell.albumLabel.text = mediaItem.albumName
        
        if let cloudServiceCapabilities = AuthorizationManager.shared.cloudServiceCapabilities, cloudServiceCapabilities.contains(.addToCloudMusicLibrary)  {
           cell.addButton.isEnabled = true
        } else {
            cell.addButton.isEnabled = false 

        }
        
        // Image loading.
        cell.coverImageView.image = nil 
        let imageURL = mediaItem.artwork.imageURL(size: CGSize(width: 90, height: 90))
        
       
        NetworkController.shared.fetchImage(url: imageURL) { (image) in
            if (cell.mediaItem?.identifier ?? "") == mediaItem.identifier {
                DispatchQueue.main.async {
                    cell.coverImageView.image = image
                }
                
            }
        }
        
       
        
        
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
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        
        guard let mediaItemController = segue.destination as? MediaItemViewController, let row = tableView.indexPathForSelectedRow?.row else {
            return
        }
        mediaItemController.mediaItem = mediaItems[row]
        
     }
    
    
}

extension MediaItemTableViewController: MediaItemTableViewCellDelegate {
    
    
    
    func songTableViewCell(_ songTableViewCell: MediaItemTableViewCell, addToPlaylist mediaItem: MediaItem) {
        let alertController = UIAlertController(title: "加到 playlist", message: nil, preferredStyle: .actionSheet)
        let playlists = AppleMusicManager.shared.getUserCreatedPlaylists()
        for playlist in playlists {
            let action = UIAlertAction(title: playlist.name!, style: .default
                , handler: { [weak self] (action) in
                    
                    AppleMusicManager.shared.addSongToPlaylist(song: mediaItem.identifier, playlist: playlist, completion: { (result) in
                        
                        let controller: UIAlertController
                        if result {
                            controller = UIAlertController(title: "加入成功", message: nil, preferredStyle: .alert)
                            
                        } else {
                            controller = UIAlertController(title: "加入失敗", message: nil, preferredStyle: .alert)
                        }
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        controller.addAction(action)
                        
                        DispatchQueue.main.async {
                            if self?.presentedViewController == nil {
                                self?.present(controller, animated: true, completion: nil)

                            } else {
                                self?.presentedViewController?.present(controller, animated: true, completion: nil)
                            }
                            
                        }
                        
                    })
                    
                    
            })
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        if presentedViewController == nil {
            present(alertController, animated: true, completion: nil)

        } else {
            presentedViewController?.present(alertController, animated: true, completion: nil)

        }
    }
    
    func songTableViewCell(_ songTableViewCell: MediaItemTableViewCell, playMediaItem mediaItem: MediaItem) {
        // if mediaItem is album, play first song 
        musicPlayerController.setQueue(with: [mediaItem.identifier])
        musicPlayerController.play()
    }
    
    
}
