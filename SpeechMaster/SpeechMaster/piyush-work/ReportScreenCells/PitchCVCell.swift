//
//  PitchCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit

class PitchCVCell: UICollectionViewCell {
    
    @IBOutlet var graphPlaceHolder: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        
    }
    
   func updatePitch(with pitch : Pitch){
       graphPlaceHolder.image = pitch.graphPlaceHolder
    }
}
