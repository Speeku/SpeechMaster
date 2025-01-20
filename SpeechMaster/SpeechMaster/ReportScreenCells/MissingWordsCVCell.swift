//
//  MissingWordsCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit

class MissingWordsCVCell: UICollectionViewCell {
    
    @IBOutlet var noOfMissingWords: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        
    }
    
    func updateMissingWords(with missingWords : MissingWords){
        noOfMissingWords.text = missingWords.noOfMissingWords
    }
}
