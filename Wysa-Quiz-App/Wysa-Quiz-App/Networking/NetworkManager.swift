//
//  NetworkManager.swift
//  Wysa-Quiz-App
//
//  Created by Jaimin Raval on 11/11/23.
//

import Foundation

class NetworkManager {
    // Using @Escaping Closure to fetch data from api & transfer it to ViewModel
    func fetchApiData(completion: @escaping(Result<QuizData, Error>) -> Void) {
        
        guard let url = URL(string: K.apiURL) else { return }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url){ data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(QuizData.self, from: data)
                completion(.success(result))
                
            } catch {
                completion(.failure(error))
                debugPrint(error.localizedDescription)
            }
        }
        task.resume()
    }
}

