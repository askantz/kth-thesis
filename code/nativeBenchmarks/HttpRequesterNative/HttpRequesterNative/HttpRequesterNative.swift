//
//  Http.swift
//  swift
//
//  Created by Anna Skantz on 2023-04-04.
//

import Foundation

public class HttpRequesterNative {
    
    private let lat = WeatherMapConfigs.LATITUDE
    private let lon = WeatherMapConfigs.LONGITUDE
    private let key = WeatherMapConfigs.API_KEY
    
    public init() {}
    
    // https://stackoverflow.com/questions/58319322/using-dispatch-group-in-multi-for-loop-with-urlsession-tasks
    public func runBenchmark(n: Int, completion: @escaping (Bool?, Error?) -> Void) {
        let apiUrlOneCall = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&appid=\(key)"
        let session = URLSession(configuration: .default)
        
        let group = DispatchGroup()
        
        for _ in 0..<n {
            group.enter()
            makeHttpCall(session: session, url: apiUrlOneCall) { result, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                group.leave()
            }
            group.wait()
        }
        
        session.invalidateAndCancel() // close the connection
        completion(true, nil)
    }
  
    private func makeHttpCall(session: URLSession, url: String, completion: @escaping (Bool?, Error?) -> Void) {
        let request = URLRequest(url: URL(string: url)!)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let httpResponse = response as? HTTPURLResponse, let data = data {
                if (200..<300).contains(httpResponse.statusCode) {
                    completion(true, nil)
                } else {
                    completion(nil, NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? ""]))
                }
            } else {
                completion(nil, NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unexpected error"]))
            }
            
        }.resume() // executes the task
    }
}
