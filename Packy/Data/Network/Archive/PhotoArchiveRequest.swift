//
//  PhotoArchiveRequest.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation

struct PhotoArchiveRequest: Encodable {
    let lastPhotoId: Int?
    var size: Int = 6

    enum CodingKeys: String, CodingKey {
        case lastPhotoId = "last-photo-id"
        case size
    }
}
