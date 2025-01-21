//
//  PronunciationCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit

class PronunciationCVCell: UICollectionViewCell {
    
   
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    
    // Data for the buttons
    let buttonOneText = (labelOne: "Period", labelTwo: "pee.ree.udh")
    let buttonTwoText = (labelOne: "Algorithm", labelTwo: "al.go.rith.um")
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        updateLabels(for: buttonOneText)
        configureButtonStyles()
    }
    
   
}



//for button design
extension PronunciationCVCell{
    
    // Action for button taps
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender == buttonOne {
            updateLabels(for: buttonOneText)
            updateButtonStyles(selected: buttonOne, deselected: buttonTwo)
        } else if sender == buttonTwo {
            updateLabels(for: buttonTwoText)
            updateButtonStyles(selected: buttonTwo, deselected: buttonOne)
        }
    }
    
    // MARK: - Helper Methods
    private func updateLabels(for text: (labelOne: String, labelTwo: String)) {
        labelOne.text = text.labelOne
        labelTwo.text = text.labelTwo
    }
    
    private func updateButtonStyles(selected: UIButton, deselected: UIButton) {
        selected.backgroundColor = .systemBlue
        selected.titleLabel?.textColor = .white
        selected.layer.borderWidth = 0
        deselected.backgroundColor = .white
        deselected.titleLabel?.textColor = .systemBlue
        deselected.layer.borderWidth = 1
        deselected.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    private func configureButtonStyles() {
        // Initial button styles
        buttonOne.layer.cornerRadius = 13
        buttonTwo.layer.cornerRadius = 13
        
        // Set the initial selected button (buttonOne)
        updateButtonStyles(selected: buttonOne, deselected: buttonTwo)
        
    }
}
