//
//  FillersCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit

class FillersCVCell: UICollectionViewCell {
    
    @IBOutlet var noOfFillerWords: UILabel!
    
    @IBOutlet var controlChevron: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        
        controlChevron.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }
    
    func updateFillers(with fillers : Fillers){
        noOfFillerWords.text = fillers.noOfFillersWords
    }
}
