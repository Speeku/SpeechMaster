//
//  CustomQuestionCell.swift
//  SpeechMaster
//
//  Created by Piyush on 22/01/25.
//

import UIKit

class CustomQuestionCell: UICollectionViewCell {
    
    @IBOutlet var questonLabel: UILabel!
    
    @IBOutlet var timeTaken: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
    }
    func updateCell(with question : QnAQuestion){
        questonLabel.text = question.questionText
        
        // Format time taken
        let minutes = Int(question.timeTaken) / 60
        let seconds = Int(question.timeTaken) % 60
        timeTaken.text = String(format: "%d:%02d", minutes, seconds)
    }
}
