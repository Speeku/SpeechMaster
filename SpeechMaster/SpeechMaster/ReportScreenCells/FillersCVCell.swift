//
//  FillersCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit

class FillersCVCell: UICollectionViewCell {
    
    @IBOutlet var noOfFillerWords: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        
    }
    
    func updateFillers(with fillers : Fillers){
        noOfFillerWords.text = fillers.noOfFillersWords
    }
}
