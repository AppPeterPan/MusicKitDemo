//
//  AppleMusicRequestFactory.swift
//  MusicKitDemo
//
//  Created by SHIH-YING PAN on 13/01/2018.
//  Copyright © 2018 SHIH-YING PAN. All rights reserved.
//

import Foundation

struct AppleMusicRequestFactory {
    
    static let appleMusicAPIBaseURLString = "api.music.apple.com"
    static let recentlyPlayedPathURLString = "/v1/me/recent/played"
    static let ratingPathURLString = "/v1/me/ratings"
    static let userStorefrontPathURLString = "/v1/me/storefront"

    static func createGetUserStorefrontRequest(developerToken: String, userToken: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = AppleMusicRequestFactory.userStorefrontPathURLString
        
        // Create and configure the `URLRequest`.
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        return urlRequest
    }
    
    static func createGetMediaItemRatingRequest(mediaItem: MediaItem, developerToken: String, userToken: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        
        urlComponents.path = "\(AppleMusicRequestFactory.ratingPathURLString)/\(mediaItem.type.rawValue)/\(mediaItem.identifier)"

        
        // Create and configure the `URLRequest`.
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        return urlRequest
    }
    
    static func createMediaItemRatingRequest(mediaItem: MediaItem, rating: Rating, developerToken: String, userToken: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = "\(AppleMusicRequestFactory.ratingPathURLString)/\(mediaItem.type.rawValue)/\(mediaItem.identifier)"

        
        // Create and configure the `URLRequest`.
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "PUT"
        let jsonDic: [String: Any] = ["type": "rating", "attributes":["value":rating.rawValue]]
        let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: [])
        urlRequest.httpBody = data
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }
    
    static func createRecentlyPlayedRequest(developerToken: String, userToken: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = AppleMusicRequestFactory.recentlyPlayedPathURLString
        
        // Create and configure the `URLRequest`.
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        return urlRequest
    }
    
    static func createSongRequest(with songId: String, countryCode: String, developerToken: String) -> URLRequest {
        
        // Create the URL components for the network call.
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = "/v1/catalog/\(countryCode)/songs/\(songId)"
        
        // Create and configure the `URLRequest`.
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    
    static func createSearchRequest(with term: String, countryCode: String, nextPath: String, developerToken: String) -> URLRequest {
        
        
        // Create the URL components for the network call.
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        var urlRequest: URLRequest
        
        if nextPath == "" {
            urlComponents.path = "/v1/catalog/\(countryCode)/search"
            let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
            let urlParameters = ["term": expectedTerms,
                                 "limit": "25", "types": "songs"]
            
            var queryItems = [URLQueryItem]()
            for (key, value) in urlParameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            
            urlComponents.queryItems = queryItems
            urlRequest = URLRequest(url: urlComponents.url!)

            
        } else {
            let urlString = "\(urlComponents.scheme!)://\(urlComponents.host!)\(nextPath)&limit=25"
            urlRequest = URLRequest(url: URL(string: urlString)!)
        }
      
        // Create and configure the `URLRequest`.
        
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
}
