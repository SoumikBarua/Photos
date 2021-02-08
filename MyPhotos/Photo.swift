//
//  PhotoModel.swift
//  MyPhotos
//
//  Created by SB on 2/6/21.
//

import UIKit

class PhotoModel: Codable {
    var url: String // Since urls will be unique, can be treated as unique keys
    var created: String
    var updated: String
}

extension PhotoModel: Equatable {
    static func == (lhs: PhotoModel, rhs: PhotoModel) -> Bool {
        // the url would dictated if two photos are the same
        return lhs.url == rhs.url
    }
}
