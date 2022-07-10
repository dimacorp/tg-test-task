//
//  TimeApiFetcher.swift
//  _idx_TelegramUI_E889EC53_ios_min9.0
//
//  Created by Dmitry Polyankovskiy on 10.07.2022.
//

import Foundation

struct ServerTime: Decodable {
    let unixtime: Int32
}

public class TimeApiFetcher {
    static func getTime(completion:@escaping (Int32?, Error?)->Void ) {
        let url = URL(string: "http://worldtimeapi.org/api/timezone/Europe/Moscow")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            let decoder = JSONDecoder()

            if let data = data {
                do {
                    let serverTime = try decoder.decode(ServerTime.self, from: data)
                    completion(serverTime.unixtime, nil)
               }catch{
                   completion(nil, error)
               }
            }
        }
        
        task.resume()
    }
}
