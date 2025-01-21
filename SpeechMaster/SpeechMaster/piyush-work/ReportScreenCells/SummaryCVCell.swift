//
//  SummaryCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit

class SummaryCVCell: UICollectionViewCell {
    
    @IBOutlet var totalTimeSpent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        
    }
    
    func updateSummary(with summary : Summary){
        totalTimeSpent.text = summary.timeSpent
    }
}
