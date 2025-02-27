//
//  ProgressCollectionViewCell.swift
//  app1
//
//  Created by Arnav Chauhan on 14/01/25.
//

import UIKit

class ProgressCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title1Percent: UILabel!
    
    @IBOutlet weak var percent1: circularProgressBar!
    
    @IBOutlet weak var topicName1: UILabel!
    
    @IBOutlet weak var title2: UILabel!
    
    @IBOutlet weak var title2percent: UILabel!
    
    @IBOutlet weak var topicName2: UILabel!
    @IBOutlet weak var percent2: circularProgressBar!
    
    @IBOutlet weak var image: UIImageView!
    
    
    @IBOutlet weak var view1: UIView!
    
    @IBOutlet weak var view2: UIView!
    
    
    
    
    
    
    
    func updateCircle1(percentage: Double, progresscolor: UIColor) {
        guard let circularProgressBar = percent1 else { return }
        circularProgressBar.progress = percentage
        circularProgressBar.lineWidth = 7
        circularProgressBar.progressColor = progresscolor
        circularProgressBar.trackColor = .white
        
    
    }
    func updateCircle2(percentage: Double, progresscolor: UIColor) {
        print("Percent too?")
        guard let circularProgressBar = percent2 else { return }
        circularProgressBar.progress = percentage
        circularProgressBar.lineWidth = 7
        circularProgressBar.progressColor = progresscolor
        circularProgressBar.trackColor = .white
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateRound()
        // Initialization code
    }
    func updateRound(){
        view1.layer.cornerRadius = 15
        view2.layer.cornerRadius = 15
        image.layer.cornerRadius = 15
        image.clipsToBounds = true
    }

}
