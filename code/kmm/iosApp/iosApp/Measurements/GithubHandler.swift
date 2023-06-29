//
//  GithubHandler.swift
//  iosApp
//
//  Created by Anna Skantz on 2023-04-21.
//

import Foundation

class GithubHandler {
    
    private let owner = GithubConfigs.OWNER
    private let repo = GithubConfigs.REPO
    private let token = GithubConfigs.TOKEN
    
    func syncToGithub(fileURL: URL, configs: BenchConfigs) {
        
        // Only sync to GitHub when this flag is true
        if !configs.shouldUploadToGithub {
            print("OBS: The measurements have not synced to GitHub, set the shouldSyncToGithub flag to true to sync.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let path = configs.githubPath + "_" + dateFormatter.string(from: Date()) + ".txt"
            
        let apiUrl = "https://api.github.com/repos/\(owner)/\(repo)/contents/\(path)"
        
        let fileData = try! Data(contentsOf: fileURL)
        let encodedData = fileData.base64EncodedString()
        
        let requestData = try! JSONEncoder().encode([
            "message": configs.commitMessage,
            "content": encodedData,
            "branch": "main"
        ])
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = requestData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading file: \(error)")
            } else if let httpResponse = response as? HTTPURLResponse,
                      let data = data {
                if (200..<300).contains(httpResponse.statusCode) {
                    print("File uploaded successfully")
                } else {
                    print("Failed to upload file: \(httpResponse.statusCode) - \(String(data: data, encoding: .utf8)!)")
                }
            }
        }.resume()
    }
    
    
}
