//
//  SongTableViewCell.swift
//  MusicKitDemo
//
//  Created by SHIH-YING PAN on 14/01/2018.
//  Copyright © 2018 SHIH-YING PAN. All rights reserved.
//

import UIKit

protocol MediaItemTableViewCellDelegate: class {
    func songTableViewCell(_ songTableViewCell: MediaItemTableViewCell, addToPlaylist mediaItem: MediaItem)
    
    func songTableViewCell(_ songTableViewCell: MediaItemTableViewCell, playMediaItem mediaItem: MediaItem)
    
   
}

class MediaItemTableViewCell: UITableViewCell {
    
    
    
    static let cellIdentifier = "MediaItemTableViewCell"

    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    
    @IBAction func addToPlaylist(_ sender: Any) {
        if let mediaItem = mediaItem {
            delegate?.songTableViewCell(self, addToPlaylist: mediaItem)
        }
    }
    
    
   
    
    @IBAction func playSong(_ sender: Any) {
        if let mediaItem = mediaItem {
            delegate?.songTableViewCell(self, playMediaItem: mediaItem)
        }
    }
    
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    weak var delegate: MediaItemTableViewCellDelegate?
    var mediaItem: MediaItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
