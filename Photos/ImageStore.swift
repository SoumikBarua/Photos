//
//  ImageStore.swift
//  Photos
//
//  Created by SB on 2/6/21.
//

import UIKit

class ImageStore {
    
    // To cache our images, reduces lag from network operation and saves mobile data
    let cache = NSCache<NSString, UIImage>()
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
}
