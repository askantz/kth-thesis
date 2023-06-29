//
//  JsonParserNative.swift
//  JsonParserNative
//
//  Created by Anna Skantz on 2023-04-06.
// https://developer.apple.com/documentation/foundation/jsonencoder
// https://developer.apple.com/documentation/foundation/jsondecoder
//

import Foundation

public class JsonParserNative {
    
    public init() {}
    
    public func runBenchmark(mockResponse: String) {
        let jsonData = mockResponse.data(using: .utf8)!
        
        do {
            // Decode the json string into struct
            let dataDecoded = try JSONDecoder().decode(GithubResponse.self, from: jsonData)
            // Encode the struct back to json string
            let dataEncoded = try JSONEncoder().encode(dataDecoded)
        } catch {
            print("Error occurred when decoding or encoding JSON: \(error)")
        }
    }
    
    public struct GithubResponse: Codable {
        var GitHub: [Event] = Array()
    }
    
    struct Event: Codable {
        let id: String
        let type: String
        let actor: Actor
        let repo: Repo
        let payload: Payload?
        let pull_request: PullRequest?
    }
    
    struct Actor: Codable {
        let id: Int
        let login: String
    }
    
    struct Repo: Codable {
        let id: Int
        let name: String
    }
    
    struct Payload: Codable {
        let action: String?
        let review: Review?
        let repository_id: Int?
    }
    
    struct Review: Codable {
        let id: Int
        let user: User
        let body: String
    }
    
    struct PullRequest: Codable {
        var url: String
        var id: Int
    }
    
    struct User: Codable {
        let login: String
        let id: Int
    }
    
}
