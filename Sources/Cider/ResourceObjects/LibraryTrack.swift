//
//  Track.swift
//  Cider
//
//  Created by Scott Hoyt on 8/2/17.
//  Copyright © 2017 Scott Hoyt. All rights reserved.
//

import Foundation

public typealias LibraryTrack = Resource<LibraryTrackAttributes, LibraryTrackRelationships>

public struct LibraryTrackAttributes: Codable {
    public let name: String
    public let artistName: String
    public let albumName: String
}

public struct LibraryTrackRelationships: Codable {
    
}
