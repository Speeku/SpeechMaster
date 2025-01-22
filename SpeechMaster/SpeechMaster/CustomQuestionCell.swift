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
    func updateCell(with question : Questions){
        questonLabel.text = question.questions
        timeTaken.text = question.timeTaken
    }
}
