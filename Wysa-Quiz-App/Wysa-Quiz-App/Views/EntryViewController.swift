//
//  ViewController.swift
//  Wysa-Quiz-App
//
//  Created by Jaimin Raval on 11/11/23.
//

import UIKit

class EntryViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var quoteLbl: UILabel!
    
    var quotes: [String: String] = [
        "Steve Jobs":       K.quote_1,
        "Albert Einstein":  K.quote_2,
        "Thomas Edison":    K.quote_3,
        "Henry Ford":       K.quote_4,
        "Wayne Gretzky":    K.quote_5,
        "Alan Kay":         K.quote_6,
        "Phil Knight":      K.quote_7,
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.showStartUI()
        }
    }
    
    
    func showStartUI() {
        let quoteAuthor = self.quotes.randomElement()?.key ?? "author Here"
        UIView.animate(withDuration: 0.7) {
            self.quoteLbl.alpha = 0
            self.startBtn.alpha = 0
            self.quoteLbl.text = "\(self.quotes[quoteAuthor] ?? "Quote Here")\n\n~ \(quoteAuthor)"
            self.quoteLbl.alpha = 1
            self.startBtn.alpha = 1
            self.quoteLbl.accessibilityLabel = self.quoteLbl.text
        }
    }
    
    
    
}

