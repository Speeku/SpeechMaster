//
//  VideoCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit

class VideoCVCell: UICollectionViewCell {
    
    @IBOutlet var showVideo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        
    }
    
    func updateVideo(with video : Video){
        showVideo.image = video.showImage
    }
}
