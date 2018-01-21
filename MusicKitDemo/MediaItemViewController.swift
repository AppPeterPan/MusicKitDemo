/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`PlayerViewController` is a `UIViewController` provides basic metadata about the currently playing `MPMediaItem`
             as well as playback controls.
*/

import UIKit
import MediaPlayer

@objcMembers
class MediaItemViewController: UIViewController {
    
    var mediaItem: MediaItem?
    var isNowPlayingView = false
    
    /// The `UIImageView` for displaying the artwork of the currently playing `MPMediaItem`.
    @IBOutlet weak var currentItemArtworkImageView: UIImageView!
    

    /// The 'UILabel` for displaying the album title of the currently playing `MPMediaItem`.
    @IBOutlet weak var currentItemAlbumLabel: UILabel!
    
    /// The 'UILabel` for displaying the artist of the currently playing `MPMediaItem`.
    @IBOutlet weak var currentItemArtistLabel: UILabel!
    
   
    @IBOutlet weak var likeButton: UIButton!
    
    
    @IBOutlet weak var dislikeButton: UIButton!
    
    @IBAction func like(_ sender: Any) {
        if let mediaItem = mediaItem {
            AppleMusicManager.shared.performAppleMusicMediaItemRating(with: mediaItem, rating: .like, userToken: AuthorizationManager.shared.userToken) { (rating, error) in
                DispatchQueue.main.async {
                    self.updateRating(rating: rating)
                }
                
            }
        }
    }
    
    
    
    @IBAction func dislike(_ sender: Any) {
        if let mediaItem = mediaItem {
            AppleMusicManager.shared.performAppleMusicMediaItemRating(with: mediaItem, rating: .dislike, userToken: AuthorizationManager.shared.userToken) { (rating, error) in
                DispatchQueue.main.async {
                    self.updateRating(rating: rating)
                }
                
            }
        }
    }
    
    /// The instance of `MusicPlayerManager` used by the `PlayerViewController` to control `MPMediaItem` playback.
    let musicPlayerController = MPMusicPlayerController.systemMusicPlayer

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the notification observer needed to respond to events from the `MusicPlayerManager`.
        
        if mediaItem == nil {
            isNowPlayingView = true
            musicPlayerController.beginGeneratingPlaybackNotifications()
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleMusicPlayerControllerNowPlayingItemDidChange),
                                                   name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                                   object: nil)
            
        }
        
        updateUI()
        updateCurrentItemMetadata()

        
       
    }
    
    deinit {
        musicPlayerController.endGeneratingPlaybackNotifications()

    }
   
    
    
    
    // MARK: UI Update Methods
    
    func updateRating(rating: Rating) {
        switch rating {
        case .dislike:
            dislikeButton.backgroundColor = UIColor.lightGray
            likeButton.backgroundColor = UIColor.white
        case .like:
            likeButton.backgroundColor = UIColor.lightGray
            dislikeButton.backgroundColor = UIColor.white
        case .noRating:
            likeButton.backgroundColor = UIColor.white
            dislikeButton.backgroundColor = UIColor.white
        }
    }
    
    func updateUI() {
       if let mediaItem = mediaItem {
            navigationItem.title = mediaItem.name
            likeButton.isHidden = false
            dislikeButton.isHidden = false
            currentItemAlbumLabel.text = mediaItem.albumName
            currentItemArtistLabel.text = mediaItem.artistName
            let url = mediaItem.artwork.imageURL(size: currentItemArtworkImageView.frame.size)
            NetworkController.shared.fetchImage(url: url, completion: { (image) in
                DispatchQueue.main.async {
                    self.currentItemArtworkImageView.image = image
                    
                }
            })
        
        AppleMusicManager.shared.performAppleMusicGetSongRating(with: mediaItem, userToken: AuthorizationManager.shared.userToken, completion: { (rating, error) in
                
                DispatchQueue.main.async {
                    self.updateRating(rating: rating)
                }
            
            })
            
        } else {
            currentItemArtworkImageView.image = nil
            navigationItem.title = "No Item"
            currentItemAlbumLabel.text = " "
            currentItemArtistLabel.text = " "
            likeButton.isHidden = true
            dislikeButton.isHidden = true

        }
       
    }
    
   
    func updateCurrentItemMetadata() {
        if isNowPlayingView {
            if let nowPlayingItem = musicPlayerController.nowPlayingItem {
                
                AppleMusicManager.shared.performAppleMusicSongLookup(with: nowPlayingItem.playbackStoreID, countryCode: AuthorizationManager.shared.cloudServiceStorefrontCountryCode, completion: { (media, error) in
                    
                    self.mediaItem = media
                    
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                })
            } else {
                self.mediaItem = nil
                self.updateUI()
            }
        } else {
            updateUI()
        }
    }
    
    // MARK: Notification Observing Methods
    
    func handleMusicPlayerControllerNowPlayingItemDidChange() {
        DispatchQueue.main.async {
            self.updateCurrentItemMetadata()
        }
    }
    

}
