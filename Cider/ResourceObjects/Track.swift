//
//  Track.swift
//  Cider
//
//  Created by Scott Hoyt on 8/2/17.
//  Copyright © 2017 Scott Hoyt. All rights reserved.
//

import Foundation

public struct TrackAttributes: Codable {
    let artistName: String
    let artwork: Artwork
    let composerName: String?
    let contentRating: ContentRating?
    let discNumber: Int
    let durationInMillis: Int?
    let genreNames: [String]
    let movementCount: Int? // Classical music only
    let movementName: String? // Classical music only
    let movementNumber: Int? // Classical music only
    let name: String
    let playParams: PlayParameters?
    let releaseDate: String
    let trackNumber: Int
    let url: URL
    let workName: String? // Classical music only
}
