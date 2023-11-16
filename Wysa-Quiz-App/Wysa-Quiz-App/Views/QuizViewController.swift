//
//  QuizViewController.swift
//  Wysa-Quiz-App
//
//  Created by Jaimin Raval on 12/11/23.
//

import UIKit

class QuizViewController: UIViewController, QuizModelDelegate {
    
    private let QuizVM = QuizViewModel()
    
    private var data: [QuizModel] = []
    private var userChoices = [Int: String]()   // Dictionary to store user choice during quiz
    private var currentIndex = 0    // To keep track of current Index
    private var userScore = 0   // To Store no. of correct answers by User
    private var attempts = 0
    //  All Labels
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var loadingLbl: UILabel!
    //  Answer Buttons
    @IBOutlet weak var ansBtn1: UIButton!
    @IBOutlet weak var ansBtn2: UIButton!
    @IBOutlet weak var ansBtn3: UIButton!
    @IBOutlet weak var ansBtn4: UIButton!
    //  Navigation Buttons
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    //  ActivityIndicator & ProgressBar
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scoreProgress: UIProgressView!
    
    
    override func viewWillAppear(_ animated: Bool) {

        DispatchQueue.main.async {
            self.hideQuizUI()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        QuizVM.delegate = self
        //  making API call, fetching data & storing it in array
        QuizVM.fetcData()
        ApplyingAnimations()
        
    }
    
    
    // delegate protocol method
    func didDataFetchedSuccessfully(result: [QuizModel]) {
        data.append(contentsOf: result)
//        debugPrint(data)   // you can printdata to see it in terminal
        DispatchQueue.main.async {
            self.updateQuizUI(index: self.currentIndex)
            self.unhideQuizUI()
        }
    }
    
    
    // delegate protocol method
    func didDataFetchedFailed(error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    
    func updateQuizUI(index: Int) {
        
        DispatchQueue.main.async {
            if index < self.data.count {
                self.updateQue(index: index)
                self.setupButtons(index: index)
                self.managingNavBtns(index: index)
                self.setProgressView(index: index)
                self.voiceOverSetup(index: index)
                
            }
        }
    }
    
//    updating qustion onTap with little animation
    func updateQue(index: Int) {
        
        guard let str = HtmlDecode.decodingHTMLElements(htmlString: self.data[index].question) else { return }
        UIView.animate(withDuration: 0.5) {
            self.questionText.alpha = 0
            self.questionText.text = str
            self.questionText.alpha = 1
        }
        
    }
//    all answer Buttons config happens here
    func setupButtons(index: Int) {
        var allAnswers:[String] = []
        ansBtn1.isEnabled = true
        ansBtn2.isEnabled = true
        ansBtn3.isEnabled = true
        ansBtn4.isEnabled = true
        // storing all 3 incorrect & 1 correct answer in array to randomize all
        if data[index].type == K.answerType[0] {
            
            guard let crrAns = HtmlDecode.decodingHTMLElements(htmlString: data[index].correct_answer) else { return }
            guard let inCrrAns = HtmlDecode.decodingHTMLElements(htmlString: data[index].incorrect_answers[0]) else { return }
            
            allAnswers.append(crrAns)
            allAnswers.append(inCrrAns)
            allAnswers.shuffle()    // to randomize place of correct answer
            
            DispatchQueue.main.async {
                self.ansBtn1.setTitle(allAnswers[0], for: .normal)
                self.ansBtn2.setTitle(allAnswers[1], for: .normal)
                self.ansBtn3.isHidden = true
                self.ansBtn4.isHidden = true
            }
            
        } else if data[index].type == K.answerType[1] {
            guard let crrAns = HtmlDecode.decodingHTMLElements(htmlString: data[index].correct_answer) else { return }
            guard let inCrrAns0 = HtmlDecode.decodingHTMLElements(htmlString: data[index].incorrect_answers[0]) else { return }
            guard let inCrrAns1 = HtmlDecode.decodingHTMLElements(htmlString: data[index].incorrect_answers[1]) else { return }
            guard let inCrrAns2 = HtmlDecode.decodingHTMLElements(htmlString: data[index].incorrect_answers[2]) else { return }
            allAnswers.append(crrAns)
            allAnswers.append(inCrrAns0)
            allAnswers.append(inCrrAns1)
            allAnswers.append(inCrrAns2)
            allAnswers.shuffle()    // to randomize place of correct answer
            
            DispatchQueue.main.async {
                self.ansBtn1.setTitle(allAnswers[0], for: .normal)
                self.ansBtn2.setTitle(allAnswers[1], for: .normal)
                self.ansBtn3.isHidden = false
                self.ansBtn4.isHidden = false
                self.ansBtn3.setTitle(allAnswers[2], for: .normal)
                self.ansBtn4.setTitle(allAnswers[3], for: .normal)
                
            }
            let allBtns = [ansBtn1, ansBtn2, ansBtn3, ansBtn4]
            for btn in allBtns{
                if data[index].correct_answer == btn?.titleLabel?.text {
                    btn?.tag = 1
                }
            }
        }
    }
    
    //hiding UI while loading data from api
    func hideQuizUI() {
        DispatchQueue.main.async {
            //  loading activity inicator
            self.loadingLbl.isHidden        = false
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            //  all labels
            self.scoreLbl.isHidden          = true
            self.questionText.isHidden      = true
            //  all buttons
            self.previousBtn.isHidden       = true
            self.nextBtn.isHidden           = true
            self.ansBtn1.isHidden           = true
            self.ansBtn2.isHidden           = true
            self.ansBtn3.isHidden           = true
            self.ansBtn4.isHidden           = true
            //  progress bar
            self.scoreProgress.isHidden     = true
            //  Tags for Answer Buttons
            self.ansBtn1.tag = 0
            self.ansBtn2.tag = 1
            self.ansBtn3.tag = 2
            self.ansBtn4.tag = 3
            //  Tags for Navigation Buttons
            self.previousBtn.tag = 0
            self.nextBtn.tag = 1
        }
    }
    
    //Unhiding UI while after loading data from api
    func unhideQuizUI() {
        DispatchQueue.main.async {
            //  all labels
            self.scoreLbl.isHidden          = false
            self.questionText.isHidden      = false
            //  all buttons
            self.ansBtn1.isHidden           = false
            self.ansBtn2.isHidden           = false
            self.ansBtn3.isHidden           = false
            self.ansBtn4.isHidden           = false
            self.previousBtn.isHidden       = false
            self.nextBtn.isHidden           = false
            //  progress bar
            self.scoreProgress.isHidden     = false
            //  loading activity inicator
            self.loadingLbl.isHidden        = true
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    
//    Function for ProgrssBar Workings
    func setProgressView(index: Int) {
        scoreProgress.trackTintColor = .lightGray
//        scoreProgress.progressTintColor = .systemBlue
        let progress = Float(index + 1) / 10
        self.scoreProgress.setProgress(Float(progress), animated: true)

    }
    
//    Setting score
    func setScore(value: Int) {
        DispatchQueue.main.async {
            self.scoreLbl.text = "Your Score: \(value)"
        }
    }

    
//    Navigation Button State Management
    func managingNavBtns(index: Int) {
        
        if index <= 0 {
            previousBtn.isEnabled = false
            nextBtn.isEnabled = true
        } else if index >= data.count - 1 {
            previousBtn.isEnabled = true
            nextBtn.isEnabled = false
        } else {
            previousBtn.isEnabled = true
            nextBtn.isEnabled = true
        }
        
        self.ansBtn1.tintColor = .systemBlue
        self.ansBtn2.tintColor = .systemBlue
        self.ansBtn3.tintColor = .systemBlue
        self.ansBtn4.tintColor = .systemBlue
    }

    
//    Providing Haptic feedback on correct & incorrect answer
    func provideHaptic(type: Bool) {
        let generator = UINotificationFeedbackGenerator()
        if type {
            generator.notificationOccurred(.success)
        } else if type == false {
            generator.notificationOccurred(.error)
        }
        
    }
    
//    Moving to next question
    func moveToNextQue() {
        if currentIndex < data.count - 1 {
            currentIndex += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updateQuizUI(index: self.currentIndex)
            }
        }
    }
    
//    alert for quiz end
    func showFinishAlert() {
        // different message for different score
        var msg = ""
        if userScore <= 2 {
            msg = "Try reading more books"
        } else if userScore <= 5 {
            msg = "It looks good"
        }else if userScore <= 7{
            msg = "Well Done"
        }else if userScore <= 10 {
            msg = "Awesome!"
        } else {
            msg = "Nothing to say"
        }
        //  creating alert
        let alertController = UIAlertController(title: "Quiz Completed!", message: msg, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Retake Quiz", style: .default, handler: { _ in
            self.currentIndex = 0
            self.userScore = 0
            self.attempts = 0
            self.setScore(value: self.userScore)
            self.userChoices.removeAll()
            self.updateQuizUI(index: self.currentIndex)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
//    navigation of all quiz questions happens here
    @IBAction func navigatingQuePressed(_ sender: UIButton) {
        // perfom all tasks for previous button pressed
        if sender.tag == 0 {
            if currentIndex > 0 {
                
                currentIndex -= 1
                self.updateQuizUI(index: self.currentIndex)
            }
        // perfom all tasks for next button pressed
        } else if sender.tag == 1 {
            if currentIndex < data.count {
                
                currentIndex += 1
                self.updateQuizUI(index: self.currentIndex)
            }
        } else {
            return
        }
    }
    
    
//    Handling User Input & Correct Answer here
    @IBAction func ansBtnPressed(_ sender: UIButton) {
        let currentTag = sender.tag
//        print(currentTag) //  uncomment this line to see tag of answer button tapped
        switch currentTag {
        case 0:
            ansBtn2.isEnabled = false
            ansBtn3.isEnabled = false
            ansBtn4.isEnabled = false
        case 1:
            ansBtn1.isEnabled = false
            ansBtn3.isEnabled = false
            ansBtn4.isEnabled = false
        case 2:
            ansBtn1.isEnabled = false
            ansBtn2.isEnabled = false
            ansBtn4.isEnabled = false
        case 3:
            ansBtn1.isEnabled = false
            ansBtn2.isEnabled = false
            ansBtn3.isEnabled = false
        default:
            return
        }
    
        if attempts < 10 {
            attempts += 1
        }
        if attempts == 10 {
            DispatchQueue.main.async {
                self.showFinishAlert()
            }
        }
        
        guard let usrAns = sender.titleLabel?.text else { return }
        guard let correctAns = HtmlDecode.decodingHTMLElements(htmlString: data[currentIndex].correct_answer) else { return }
        if usrAns == correctAns {
            if userChoices[currentIndex] == nil {
                userChoices.updateValue(usrAns, forKey: currentIndex)
                DispatchQueue.main.async {
                    self.userScore += 1
                    self.setScore(value: self.userScore)
//                    print(self.userChoices)   // uncomment this line to see user's correct answers
                }
            }
            btnColorFeedback(color: .green, btn: sender, ans: true)
            
        } else {
            btnColorFeedback(color: .red, btn: sender, ans: false)
        }
    }
  
    func btnColorFeedback(color: UIColor, btn: UIButton, ans: Bool) {
        DispatchQueue.main.async {
            btn.tintColor = color
            self.btnTapped(btn: btn, rightAns: ans)
            self.provideHaptic(type: ans)
            self.moveToNextQue()
        }
    }
//  all voiceover functionality is enabled by this method
    func voiceOverSetup(index: Int) {
        scoreLbl.accessibilityLabel = "Your Score: \(userScore)"
        questionText.accessibilityLabel = self.data[index].question
        ansBtn1.accessibilityLabel = ansBtn1.currentTitle
        ansBtn2.accessibilityLabel = ansBtn2.currentTitle
        ansBtn3.accessibilityLabel = ansBtn3.currentTitle
        ansBtn4.accessibilityLabel = ansBtn4.currentTitle
        
    }
    
    // all Animations happens here
    func ApplyingAnimations() {
        ansBtn1.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        ansBtn2.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        ansBtn3.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        ansBtn4.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
    }
    
    @objc func btnTapped(btn: UIButton, rightAns: Bool) {
        
        if rightAns {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.0
            animation.toValue = 0.8
            animation.duration = 0.2
            animation.autoreverses = true
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            btn.layer.removeAllAnimations()
            btn.layer.add(animation, forKey: "scaleAnimation")
        } else {
            //do different animation here for wrong answer
            let midX = btn.center.x
            let midY = btn.center.y
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.08
            animation.repeatCount = 2
            animation.autoreverses = true
            animation.fromValue = CGPoint(x: midX - 10, y: midY)
            animation.toValue = CGPoint(x: midX + 10, y: midY)
            btn.layer.removeAllAnimations()
            btn.layer.add(animation, forKey: "position")
            
        }
        
    }
    
}




//  logic is wrong for completion of quiz, Fix it ☑️
//  Testing of VoiceOver(fixing any implemetation) ☑️
//  fixing wierd  signs like &#0239; in data from API ☑️
//  adding combine
//  cleaning all unnecessary code, comments and refactoring code ☑️

//  locking all other buttons when one btn is pressed ☑️
//  recheck MVVM structure ☑️
//  rename the app? ☑️
//  what to do about API falling? ☑️
//  check how many answers are there so we can display only that much buttons ☑️
//  fix previous navigation button workings ☑️
//  touch area is too low for nav button ☑️
//  handle correct answer with green fill and else with red fill ☑️
//  how to give haptic feeback on correct answer ☑️
//  no repetation of score should happen, persist the user choice in a Set ☑️
//  fixing Fatal error: Index out of range at the ends of nav buttons ☑️
//  fixing autolayout of all buttons(specially nav buttons) ☑️
//  Check that action sheet is showing on last que only ☑️
//  Implementing reset button ☑️
//  adding animations ☑️
//  design icon for app ☑️
//  design and implement LauncScreen ☑️
//
