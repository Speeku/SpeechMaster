//
//  ProgressCellCollectionViewCell.swift
//  SpeechMaster
//
//  Created by Arnav Chauhan on 27/02/25.
//

import UIKit

class ProgressCellCollectionViewCell: UICollectionViewCell {
    
    //outlets
    @IBOutlet var title : UILabel!
    @IBOutlet var fileName : UILabel!
    @IBOutlet var percent : circularProgressBar!
    @IBOutlet weak var view : UIView!
    @IBOutlet var percent1 : UILabel!
    @IBOutlet weak var image : UIImageView!
    func updateCircle1(percentage: Double, progresscolor: UIColor) {
        guard let circularProgressBar = percent else { return }
        circularProgressBar.progress = percentage
        circularProgressBar.lineWidth = 12
        circularProgressBar.progressColor = progresscolor
        circularProgressBar.trackColor = .init(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)

        
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 12
        image.layer.cornerRadius = 12
        image.clipsToBounds = true
        view.clipsToBounds = true
    }
}
