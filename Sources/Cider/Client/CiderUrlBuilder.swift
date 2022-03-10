//
//  CiderUrlBuilder.swift
//  Cider
//
//  Created by Scott Hoyt on 8/1/17.
//  Copyright © 2017 Scott Hoyt. All rights reserved.
//

import Foundation

protocol UrlBuilder {
    func searchRequest(term: String, limit: Int?, offset: Int?, types: [MediaType]?) -> URLRequest
    func searchHintsRequest(term: String, limit: Int?, types: [MediaType]?) -> URLRequest
    func fetchRequest(mediaType: MediaType, id: String, include: [Include]?) -> URLRequest
    func relationshipRequest(path: String, limit: Int?, offset: Int?) -> URLRequest
    func libraryPlaylistsRequest(limit: Int?, offset: Int?) -> URLRequest
    func libraryTrackOfPlaylistIDRequest(playlistID: String, limit: Int?, offset: Int?) -> URLRequest
    func libraryCreatePlaylistRequest(name: String) -> URLRequest
    func libraryAdd(songID: String, toPlaylist playlistID: String) -> URLRequest
}

public enum CiderUrlBuilderError: Error {
    case noUserToken
}

// MARK: - Constants

private struct AppleMusicApi {
    // Base
    static let baseURLScheme = "https"
    static let baseURLString = "api.music.apple.com"
    static let baseURLApiVersion = "/v1"

    // Search
    static let searchPath = "v1/catalog/{storefront}/search"
    static let searchHintPath = "v1/catalog/{storefront}/search/hints"
    
    // Parameteres
    static let termParameter = "term"
    static let limitParameter = "limit"
    static let offsetParameter = "offset"
    static let typesParameter = "types"

    // Fetch
    static let fetchPath = "v1/catalog/{storefront}/{mediaType}/{id}"
    static let fetchInclude = "include"
    
    // User
    static let libraryPlaylistsPath = "v1/me/library/playlists"
    static let libraryFetchPath = "v1/me/library/{mediaType}/{id}"
}

// MARK: - UrlBuilder

struct CiderUrlBuilder: UrlBuilder {

    // MARK: Inputs

    let storefront: Storefront
    let developerToken: String
    let userToken: String?
    private let cachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
    private let timeout: TimeInterval = 5

    // MARK: Init

    init(storefront: Storefront, developerToken: String, userToken: String? = nil) {
        self.storefront = storefront
        self.developerToken = developerToken
        self.userToken = userToken
    }

    private var baseApiUrl: URL {
        var components = URLComponents()

        components.scheme = AppleMusicApi.baseURLScheme
        components.host = AppleMusicApi.baseURLString

        return components.url!
    }

    // MARK: Construct urls
    private func libraryAddSongToPlaylistID(_ playlistID: String) -> URL {
        var components = URLComponents()
        
        components.path = AppleMusicApi.libraryFetchPath.addMediaType(.playlists).addId(playlistID) + "/tracks"
        
        // Construct final url
        return components.url(relativeTo: baseApiUrl)!
    }
    private func libraryCreatePlaylistUrl() -> URL {
        var components = URLComponents()
        
        components.path = AppleMusicApi.libraryPlaylistsPath
        
        // Construct final url
        return components.url(relativeTo: baseApiUrl)!
    }
    
    private func libraryTrackOfPlaylistIDUrl(playlistID: String, limit: Int?, offset: Int?) -> URL {
        var components = URLComponents()
        
        components.path = AppleMusicApi.libraryFetchPath.addMediaType(.playlists).addId(playlistID) + "/tracks"
        
        // Construct Query
        components.apply(limit: limit)
        components.apply(offset: offset)
        
        // Construct final url
        return components.url(relativeTo: baseApiUrl)!
    }
    
    private func libraryPlaylistsUrl(limit: Int?, offset: Int?) -> URL {
        var components = URLComponents()
        components.path = AppleMusicApi.libraryPlaylistsPath
        
        // Construct Query
        components.apply(limit: limit)
        components.apply(offset: offset)
        
        // Construct final url
        return components.url(relativeTo: baseApiUrl)!
    }
    
    private func seachUrl(term: String, limit: Int?, offset: Int?, types: [MediaType]?) -> URL {

        // Construct url path

        var components = URLComponents()

        components.path = AppleMusicApi.searchPath.addStorefront(storefront)

        // Construct Query
        components.apply(searchTerm: term)
        components.apply(limit: limit)
        components.apply(offset: offset)
        components.apply(mediaTypes: types)

        // Construct final url
        return components.url(relativeTo: baseApiUrl)!
    }

    private func searchHintsUrl(term: String, limit: Int?, types: [MediaType]?) -> URL {

        // Construct url path

        var components = URLComponents()

        components.path = AppleMusicApi.searchHintPath.addStorefront(storefront)

        // Construct Query
        components.apply(searchTerm: term)
        components.apply(limit: limit)
        components.apply(mediaTypes: types)

        // Construct final url
        return components.url(relativeTo: baseApiUrl)!
    }

    private func fetchUrl(mediaType: MediaType, id: String, include: [Include]?) -> URL {
        var components = URLComponents()
        components.path = AppleMusicApi.fetchPath.addStorefront(storefront).addMediaType(mediaType).addId(id)
        components.apply(include: include)

        return components.url(relativeTo: baseApiUrl)!.absoluteURL
    }

    private func relationshipUrl(path: String, limit: Int?, offset: Int?) -> URL {
        var components = URLComponents()

        components.path = path
        components.apply(limit: limit)
        components.apply(offset: offset)

        return components.url(relativeTo: baseApiUrl)!.absoluteURL
    }

    // MARK: Construct requests
    func libraryAdd(songID: String, toPlaylist playlistID: String) -> URLRequest {
        let url = libraryAddSongToPlaylistID(playlistID)
        let request = constructRequest(url: url)
        
        let info = """
        {
            "data":[
                {
                    "id":"\(songID)",
                    "type":"songs"
                }
            ]
        }
        """
        let data = info.data(using: .utf8)!
        
        return addBody(body: data, request: request)
    }
    
    func libraryCreatePlaylistRequest(name: String) -> URLRequest {
        let url = libraryCreatePlaylistUrl()
        let request = constructRequest(url: url)
        
        let info = """
            {
                "attributes":{
                    "name":"\(name)"
                }
            }
 """
        let data = info.data(using: .utf8)!

        return addBody(body: data, request: request)
    }
    func libraryTrackOfPlaylistIDRequest(playlistID: String, limit: Int?, offset: Int?) -> URLRequest {
        let url = libraryTrackOfPlaylistIDUrl(playlistID: playlistID, limit: limit, offset: offset)
        return constructRequest(url: url)
    }
    
    func libraryPlaylistsRequest(limit: Int?, offset: Int?) -> URLRequest {
        let url = libraryPlaylistsUrl(limit: limit, offset: offset)
        return constructRequest(url: url)
    }
    
    func searchRequest(term: String, limit: Int?, offset: Int?, types: [MediaType]?) -> URLRequest {
        let url = seachUrl(term: term, limit: limit, offset: offset, types: types)
        return constructRequest(url: url)
    }

    func searchHintsRequest(term: String, limit: Int?, types: [MediaType]?) -> URLRequest {
        let url = searchHintsUrl(term: term, limit: limit, types: types)
        return constructRequest(url: url)
    }

    func fetchRequest(mediaType: MediaType, id: String, include: [Include]?) -> URLRequest {
        let url = fetchUrl(mediaType: mediaType, id: id, include: include)
        return constructRequest(url: url)
    }

    func relationshipRequest(path: String, limit: Int?, offset: Int?) -> URLRequest {
        let url = relationshipUrl(path: path, limit: limit, offset: offset)
        return constructRequest(url: url)
    }

    private func constructRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request = addAuth(request: request)
        request = addUserToken(request: request)
        return request
    }

    private func addBody(body: Data, request: URLRequest) -> URLRequest {
        var request = request
        
        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    // MARK: Add authentication
    private func addAuth(request: URLRequest) -> URLRequest {
        var request = request

        let authHeader = "Bearer \(developerToken)"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")

        return request
    }

    private func addUserToken(request: URLRequest) -> URLRequest {
        if let userToken = userToken {
            var request = request
            request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
            return request
        }

        return request
    }
}

// MARK: - Helpers

private extension String {
    func replaceSpacesWithPluses() -> String {
        return replacingOccurrences(of: " ", with: "+")
    }

    func addStorefront(_ storefront: Storefront) -> String {
        return replacingOccurrences(of: "{storefront}", with: storefront.rawValue)
    }

    func addId(_ id: String) -> String {
        return replacingOccurrences(of: "{id}", with: id)
    }

    func addMediaType(_ mediaType: MediaType) -> String {
        return replacingOccurrences(of: "{mediaType}", with: mediaType.rawValue)
    }
}

private extension URLComponents {
    mutating func createQueryItemsIfNeeded() {
        if queryItems == nil {
            queryItems = []
        }
    }

    mutating func apply(searchTerm: String) {
        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.termParameter, value: searchTerm.replaceSpacesWithPluses()))
    }

    mutating func apply(mediaTypes: [MediaType]?) {
        guard let mediaTypes = mediaTypes else { return }

        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.typesParameter, value: mediaTypes.map { $0.rawValue }.joined(separator: ",")))
    }

    mutating func apply(limit: Int?) {
        guard let limit = limit else { return }

        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.limitParameter, value: "\(limit)"))
    }

    mutating func apply(offset: Int?) {
        guard let offset = offset else { return }

        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.offsetParameter, value: "\(offset)"))
    }

    mutating func apply(include: [Include]?) {
        guard let include = include else { return }

        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.fetchInclude, value: include.map { $0.rawValue }.joined(separator: ",")))
    }
}
