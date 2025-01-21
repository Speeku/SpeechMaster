//
//  PaceCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit
import Charts

class PaceCVCell: UICollectionViewCell {
    
  //  @IBOutlet var wordPerMin: UILabel!
 
   
    @IBOutlet var paceMeter: PaceMeterView!
    @IBOutlet var graphPlaceHolder: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        paceMeter.translatesAutoresizingMaskIntoConstraints = false
           
        // constraints for pace meter
           NSLayoutConstraint.activate([
            paceMeter.topAnchor.constraint(equalTo: contentView.topAnchor , constant: 30),
            paceMeter.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
            paceMeter.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            paceMeter.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -250)
           ])
    
        // how much pace
        paceMeter.value = 180
        
    }
    
    func updatePace(with pace : Pace){
      // wordPerMin.text = pace.wordsPerMin
        graphPlaceHolder.image = pace.graphPlaceHolder
    }
    
    
}
