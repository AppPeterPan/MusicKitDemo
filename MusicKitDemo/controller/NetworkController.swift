//
//  NetworkController.swift
//  MusicKitDemo
//
//  Created by SHIH-YING PAN on 20/01/2018.
//  Copyright © 2018 SHIH-YING PAN. All rights reserved.
//

import UIKit

struct NetworkController {
    static let shared = NetworkController()
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
