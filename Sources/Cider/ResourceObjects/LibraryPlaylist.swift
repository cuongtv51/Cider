//
//  Playlist.swift
//  Cider
//
//  Created by Scott Hoyt on 8/25/17.
//  Copyright © 2017 Scott Hoyt. All rights reserved.
//

import Foundation

public typealias LibraryPlaylist = Resource<LibraryPlaylistAttributes, LibraryPlaylistRelationships>

public struct LibraryPlaylistAttributes: Codable {
    public let name: String
}

public struct LibraryPlaylistRelationships: Codable {
    
}
