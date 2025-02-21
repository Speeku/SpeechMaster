//
//  ReportViewController.swift
//  SpeechMaster
//
//  Created by Arnav Chauhan on 16/02/25.
//

import UIKit

class ReportViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let qna_dataController = QnaDataController.shared
    var questionData: String = ""
    var selectedIndex: Int = 0
    
    // Add properties for session data
    var sessionId: UUID!
    var sessionTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Verify we have the correct data
        print("Showing report for session: \(sessionTitle ?? "Unknown")")
        print("Session ID: \(sessionId?.uuidString ?? "Unknown")")
        
        if let question = qna_dataController.questions[safe: selectedIndex] {
            print("Question text: \(question.questionText)")
            print("User answer: \(question.userAnswer)")
            print("Time taken: \(question.timeTaken) seconds")
        }
    }
    
    private func setupUI() {
        title = "Question Review"
        
        // Collection view setup
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Remove extra top space
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
            flowLayout.minimumLineSpacing = 16
            flowLayout.minimumInteritemSpacing = 0
        }
        
        collectionView.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3  // Question, Answer, and Suggested Answer cells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let question = qna_dataController.questions[safe: selectedIndex] else {
            return UICollectionViewCell()
        }
        
        switch indexPath.row {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "question_cell", for: indexPath) as? QuestionCollectionViewCell else {
                return UICollectionViewCell()
            }
            configureQuestionCell(cell, with: question)
            return cell
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "answer_cell", for: indexPath) as? AnswerCollectionViewCell else {
                return UICollectionViewCell()
            }
            configureAnswerCell(cell, with: question)
            return cell
            
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggested_answer_cell", for: indexPath) as? SuggestedCollectionViewCell else {
                return UICollectionViewCell()
            }
            configureSuggestedAnswerCell(cell, with: question)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    private func configureQuestionCell(_ cell: QuestionCollectionViewCell, with question: QnAQuestion) {
        let timeString = String(format: "%.1f seconds", question.timeTaken)
        cell.question_textView.text = "Question \(selectedIndex + 1)\n\nTime taken: \(timeString)\n\n\(question.questionText)"
        styleCell(cell, backgroundColor: .systemGray6, textView: cell.question_textView)
    }
    
    private func configureAnswerCell(_ cell: AnswerCollectionViewCell, with question: QnAQuestion) {
        cell.answer_textView.text = "Your Answer\n\n\(question.userAnswer)"
        styleCell(cell, backgroundColor: .systemGray4, textView: cell.answer_textView)
    }
    
    private func configureSuggestedAnswerCell(_ cell: SuggestedCollectionViewCell, with question: QnAQuestion) {
        cell.suggested_textView.text = "Suggested Answer\n\n\(question.suggestedAnswer)"
        styleCell(cell, backgroundColor: UIColor.systemGreen.withAlphaComponent(0.15), textView: cell.suggested_textView)
    }
    
    private func styleCell(_ cell: UICollectionViewCell, backgroundColor: UIColor, textView: UITextView) {
        // Cell styling
        cell.contentView.backgroundColor = backgroundColor
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.layer.masksToBounds = true
        
        // Shadow
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 6
        cell.layer.shadowOpacity = 0.1
        cell.layer.masksToBounds = false
        
        // TextView styling
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.isEditable = false
    }
}

// Safe array access
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension ReportViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        let height: CGFloat = 210  // Fixed height for each cell
        return CGSize(width: width, height: height)
    }
}
