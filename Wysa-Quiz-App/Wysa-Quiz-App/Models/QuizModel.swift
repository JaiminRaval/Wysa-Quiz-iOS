//
//  QuizModel.swift
//  Wysa-Quiz-App
//
//  Created by Jaimin Raval on 11/11/23.
//

import Foundation

// Model for API 
struct QuizData: Codable {
    let results: [QuizModel]
}


struct QuizModel: Codable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}
