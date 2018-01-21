//
//  AppleMusicManager.swift
//  MusicKitDemo
//
//  Created by SHIH-YING PAN on 13/01/2018.
//  Copyright © 2018 SHIH-YING PAN. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

enum Rating: Int {
    case dislike = -1
    case noRating = 0
    case like = 1

}

class AppleMusicManager {
    

    static let shared = AppleMusicManager()
    var developerToken = ""
   
    func fetchDeveloperTokenFromNetwork(completion: () -> ()) {
        
        developerToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlFDTjVIWjUzTk4ifQ.eyJpc3MiOiJHNEhMOThMWDZMIiwiaWF0IjoxNTE2NTAyMzU1LCJleHAiOjE1MTY1NDU1NTV9.2d1W7lqX2g2AG3Pzbe-UJ6-yoCXhaAxsqssEE98hIipdB7BORIJUpzE9mKMmrwv5ibAq0HCnStfOzckhFMUXBw"
        completion()
    }

    func createPlaylist(name: String, description: String, completion: @escaping (Bool) -> ()) {
        let playlistUUID = UUID()
        let playlistCreationMetadata = MPMediaPlaylistCreationMetadata(name: name)
        playlistCreationMetadata.descriptionText = description
        
        MPMediaLibrary.default().getPlaylist(with: playlistUUID, creationMetadata: playlistCreationMetadata) { (playlist, error) in
            guard error == nil else {
                completion(false)
                return
            }
            
        }
        
        completion(true)
    }
    
    func addSongToPlaylist(song: String, playlist: MPMediaPlaylist, completion: @escaping (Bool) -> ()) {
        playlist.addItem(withProductID: song, completionHandler: { (error) in
            
            
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)

        })
    }
    
    
    func getPlaylists() -> [MPMediaPlaylist] {
        let playlistsQuery = MPMediaQuery.playlists()
        if let playlists = playlistsQuery.collections as? [MPMediaPlaylist]  {
            
            return playlists
        } else {
            return [MPMediaPlaylist]()
        }
    }
    
    func getUserCreatedPlaylists() -> [MPMediaPlaylist] {
        let playlistsQuery = MPMediaQuery.playlists()
        if let playlists = playlistsQuery.collections as? [MPMediaPlaylist]  {
            return playlists.filter({ (playlist) -> Bool in
                if playlist.playlistAttributes.rawValue == 0 && playlist.name != "已購買的音樂" {
                    return true
                } else {
                    return false
                }
            })
        } else {
            return [MPMediaPlaylist]()
        }
    }
    
    
    func processMediaItems(from json: Data) throws -> ([MediaItem], String?) {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        var songMediaItems = [MediaItem]()
        var next: String?
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            next = songsDictionary[ResponseRootJSONKeys.next] as? String
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                
                songMediaItems = try dataArray.map { try MediaItem(json: $0) }
            }
        }
        
        return (songMediaItems, next)
    }
    
   
    
    func processRating(from json: Data) throws -> Rating {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let dataArray = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        
        guard let attributes = dataArray.first?[MediaItem.JSONKeys.attributes] as? [String: Int] else {
            throw SerializationError.missing(MediaItem.JSONKeys.attributes)
        }
        
        guard let value = attributes[MediaItem.JSONKeys.value] else {
            throw SerializationError.missing(MediaItem.JSONKeys.name)
        }
        
        if let rating = Rating(rawValue: value) {
            return rating
        } else {
            return .noRating
        }

    }
    
    func processRecentItems(from json: Data) throws -> [MediaItem] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let dataArray = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        
        var songMediaItems = [MediaItem]()
        songMediaItems = try dataArray.map { try MediaItem(json: $0) }
        return songMediaItems
    }
    
    func processItem(from json: Data) throws -> MediaItem {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let dataArray = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        
        var mediaItems = try dataArray.map { try MediaItem(json: $0) }
        return mediaItems[0]
    }
    
    func performAppleMusicSongLookup(with songId: String, countryCode: String, completion: @escaping (MediaItem?, Error?) -> ()) {
        
      
        let urlRequest = AppleMusicRequestFactory.createSongRequest(with: songId, countryCode: countryCode, developerToken: developerToken)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                
                completion(nil, error)
                return
            }
            
            do {
                let mediaItem = try self.processItem(from: data!)
                completion(mediaItem, nil)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
    func performAppleMusicGetSongRating(with mediaItem: MediaItem, userToken: String, completion: @escaping (Rating, Error?) -> ()) {
        
        let urlRequest = AppleMusicRequestFactory.createGetMediaItemRatingRequest(mediaItem: mediaItem, developerToken: developerToken, userToken: userToken)
        
        //print("urlRequest", urlRequest, urlRequest.allHTTPHeaderFields)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else {
                completion(.noRating, error)
                return
            }
            /*
            if let jsonString = String(data: data, encoding: .utf8) {
                print("performAppleMusicGetSongRating", jsonString)

            }
            */
            
            
            do {
                let rating = try self.processRating(from: data)
                completion(rating, error)
                
    
            } catch {
                completion(.noRating, error)

            }
            
        }
        
        task.resume()
    }
    
    func performAppleMusicMediaItemRating(with mediaItem: MediaItem, rating: Rating, userToken: String, completion: @escaping (Rating, Error?) -> ()) {
        
        let urlRequest = AppleMusicRequestFactory.createMediaItemRatingRequest(mediaItem: mediaItem, rating: rating, developerToken: developerToken, userToken: userToken)
        
        //print("urlRequest", urlRequest, urlRequest.allHTTPHeaderFields)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else {
                completion(.noRating, error)
                return
            }
            /*
             if let jsonString = String(data: data, encoding: .utf8) {
             print("performAppleMusicGetSongRating", jsonString)
             
             }
             */
            
            
            do {
                let rating = try self.processRating(from: data)
                completion(rating, error)
                
                
            } catch {
                completion(.noRating, error)
                
            }
            
        }
        
        task.resume()
    }
    
    func performAppleMusicCatalogSearch(with term: String = "", countryCode: String = "", nextPath: String = "", completion: @escaping ( [MediaItem], String?, Error?) -> ()) {
        
      
        
        let urlRequest = AppleMusicRequestFactory.createSearchRequest(with: term, countryCode: countryCode, nextPath: nextPath, developerToken: developerToken)

        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else {
                completion([], nil, error)
               
                return
            }
            
            do {
                let (songs, next) = try self.processMediaItems(from: data)
                completion(songs, next, nil)
                
            } catch {
                completion([], nil, error)
            }
        }
        
        task.resume()
    }
    
    func performAppleMusicGetRecentlyPlayed(userToken: String, completion: @escaping ( [MediaItem], Error?) -> ()) {
        
        let urlRequest = AppleMusicRequestFactory.createRecentlyPlayedRequest(developerToken: developerToken, userToken: userToken)
        
        //print("urlRequest", urlRequest, urlRequest.allHTTPHeaderFields)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else {
                completion([], error)
                return
            }
            
            do {
                let songs = try self.processRecentItems(from: data)
                completion(songs, nil)
                
            } catch {
                completion([], error)
            }
        }
        
        task.resume()
    }
}
