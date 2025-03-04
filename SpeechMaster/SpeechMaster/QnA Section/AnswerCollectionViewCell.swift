//
//  AnswerCollectionViewCell.swift
//  SpeechMaster
//
//  Created by Arnav Chauhan on 16/02/25.
//

import UIKit

class AnswerCollectionViewCell: UICollectionViewCell {
    @IBOutlet var answer_textView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
    }
}
