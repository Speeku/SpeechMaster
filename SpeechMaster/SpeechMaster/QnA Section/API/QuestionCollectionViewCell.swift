//
//  QuestionCollectionViewCell.swift
//  SpeechMaster
//
//  Created by Arnav Chauhan on 16/02/25.
//

import UIKit

class QuestionCollectionViewCell: UICollectionViewCell {
    
    //outlets
    @IBOutlet var question_textView: UITextView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style the text view
        question_textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        question_textView.font = .systemFont(ofSize: 16)
        question_textView.isEditable = false
        question_textView.backgroundColor = .clear
        
        // Style the cell
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        // Add a title label if needed
        let titleLabel = UILabel()
        titleLabel.text = "Question"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        // Add constraints for titleLabel
    }
}
