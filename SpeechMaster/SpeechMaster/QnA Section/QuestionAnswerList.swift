//
//  QuestionAnswerList.swift
//  SpeechMaster
//
//  Created by Piyush on 22/01/25.
//

import UIKit

class QuestionAnswerList: UIViewController {
    let dataSource = DataController.shared
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var answerButton: UIButton!
    
    var isViewingExistingSession: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        // Hide save button if viewing existing session
        saveButton.isHidden = isViewingExistingSession
        
        // Disable answer button initially
        answerButton?.isEnabled = false
        
        // Simple navigation setup
        navigationItem.title = "Q/A Report"
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Add this to verify save button is connected
        print("Save button: \(String(describing: saveButton))")
        
        // Manually connect the save button action if needed
        saveButton.target = self
        saveButton.action = #selector(saveButtonTapped(_:))
    }
     let qna_dataController = QnaDataController.shared
    func generateLayout() -> UICollectionViewLayout{
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: 10,
            bottom: 0,
            trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: 10,
            bottom: 0,
            trailing: 10)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        print("Save button tapped") // Debug print
        
        // First check if we have any questions to save
        guard !qna_dataController.questions.isEmpty else {
            // Show alert if no questions available
            let alert = UIAlertController(
                title: "Error",
                message: "No questions available to save",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Get the next session number - convert UUID to string
        //let scriptIdString = HomeViewModel.shared.currentScriptID.uuidString
        let sessionNumber = dataSource.getQnASessions(for: HomeViewModel.shared.currentScriptID).count + 1
        let sessionName = "Q&A Session \(sessionNumber)"
        
        // Get session ID from first question - now safe since we checked questions array isn't empty
        let sessionId = qna_dataController.questions.first!.qna_session_Id
        
        // Create and save session
        let qnaSession = QnASession(
            id: sessionId,
            scriptId: HomeViewModel.shared.currentScriptID,
            createdAt: Date(),
            title: sessionName
        )
        
        // Save data
        DataController.shared.addQnASessions(qnaSession)
        DataController.shared.addQnAQuestions(qna_dataController.questions)
        
        // Show success alert and navigate home
        let alert = UIAlertController(
            title: "Success",
            message: "Session saved successfully!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Navigate back to home screen
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let initialVC = storyboard.instantiateInitialViewController() {
                    window.rootViewController = initialVC
                    window.makeKeyAndVisible()
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    // Move prepare(for segue:) outside of saveButtonTapped
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QuestionDetailVC",
           let reportVC = segue.destination as? ReportViewController,
           let data = sender as? (question: String, index: Int) {
            // Pass the complete question data
            reportVC.selectedIndex = data.index
            reportVC.questionData = data.question
            
            // Print debug info
            print("Preparing to show report for question \(data.index + 1)")
            print("Question text: \(data.question)")
            
            // Set the questions in QnaDataController to ensure they're available
            reportVC.qna_dataController.questions = self.qna_dataController.questions
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension QuestionAnswerList : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return qna_dataController.questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as? CustomQuestionCell else {
            print("Cell not found")
            return UICollectionViewCell()
        }
        
        let question = qna_dataController.questions[indexPath.row]
        
        // Update cell with question data
        cell.updateCell(with: question)
        
        // Debug print
        print("⏱️ Cell \(indexPath.row) time: \(question.timeTaken) seconds")
        print("📝 Question belongs to session: \(question.qna_session_Id)")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedQuestion = qna_dataController.questions[indexPath.row]
        print("Selected question: \(selectedQuestion.questionText)")
        print("From session: \(selectedQuestion.qna_session_Id)")
        
        let data = (question: selectedQuestion.questionText, index: indexPath.row)
        performSegue(withIdentifier: "QuestionDetailVC", sender: data)
    }
}

extension QuestionAnswerList {
    func questionsGenerated() {
        // Enable answer button once questions are loaded
        DispatchQueue.main.async { [weak self] in
            self?.answerButton?.isEnabled = true
            self?.qna_dataController.isQuestionsLoaded = true
        }
    }
}
   

