//
//  OriginalityCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit

class OriginalityCVCell: UICollectionViewCell {
    
    @IBOutlet var originalityStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        
    }
    
   func updateOriginality(with originality : Originality){
       originalityStatus.text = originality.originalityStatus
    }
}
