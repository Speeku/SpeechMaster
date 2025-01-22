//
//  questionAndAnsVC.swift
//  SpeechMaster
//
//  Created by Piyush on 22/01/25.
//

import UIKit

class questionAndAnsVC: UIViewController {

    
    @IBOutlet var questionProgressBar: UIProgressView!
    
    @IBOutlet var questions: UILabel!
    
    
    @IBOutlet var userAnswer: UITextView!
    
    @IBOutlet var backwardButton: UIButton!
   
    @IBOutlet var forwardButton : UIButton!
   
    @IBOutlet var answerButton: UIButton!
    
       private var isAnimating = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Question 1"
    
        //    backwardButton.isHidden = true
        updateUI()
        
        userAnswer.text = ""
        
  
    }
    
    var currentQuestionIndex = 0
    
    func updateUI(){
        questions.text = questionsList[currentQuestionIndex].questions
        
        let progress = Float(currentQuestionIndex + 1) / Float(questionsList.count)
        questionProgressBar.progress = progress
        
        self.navigationItem.title = "Question \(currentQuestionIndex + 1)"
        if currentQuestionIndex == 0 {
            backwardButton.isHidden = true
        }else{
            backwardButton.isHidden = false
        }
        
            
    }
    
   
    @IBAction func answerButton(_ sender: Any) {
       
    }
    
    @IBAction func forwardButton(_ sender: Any) {
        guard currentQuestionIndex < questionsList.count - 1 else { return }
        currentQuestionIndex += 1
               
               // Update the UI
        updateUI()
        
        backwardButton.isHidden = false
        
    }
    
    @IBAction func backwardButton(_ sender: Any) {
        guard currentQuestionIndex > 0 else { return }
        
            currentQuestionIndex -= 1
            
            // Update the UI
            updateUI()
        
      
    }
    
}
