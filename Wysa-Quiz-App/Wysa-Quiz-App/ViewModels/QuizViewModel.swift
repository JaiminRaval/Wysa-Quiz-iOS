//
//  QuizViewModel.swift
//  Wysa-Quiz-App
//
//  Created by Jaimin Raval on 12/11/23.
//

import Foundation

protocol QuizModelDelegate: AnyObject {
    func didDataFetchedSuccessfully(result: [QuizModel])
    func didDataFetchedFailed(error: Error)
}


class QuizViewModel {
    
    weak var delegate: QuizModelDelegate?
    private let networkManager = NetworkManager()
    
    func fetcData() {
        networkManager.fetchApiData { result in
            
            switch result {
                
            case .success(let data):
                self.delegate?.didDataFetchedSuccessfully(result: data.results)
              
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.delegate?.didDataFetchedFailed(error: error)
                
            }
        }
    }
    
}

