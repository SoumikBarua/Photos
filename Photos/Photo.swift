//
//  Photo.swift
//  Photos
//
//  Created by SB on 2/6/21.
//

import UIKit

class Photo: Codable {
    var url: String // Since urls will be unique, can be treated as unique keys
    var created: String
    var updated: String
}

extension Photo: Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        // the url would dictated if two photos are the same
        return lhs.url == rhs.url
    }
}
