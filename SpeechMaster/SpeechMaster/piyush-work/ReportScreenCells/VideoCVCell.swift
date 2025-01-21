//
//  VideoCVCell.swift
//  SpeechMaster
//
//  Created by Piyush on 17/01/25.
//

import UIKit
import AVKit

class VideoCVCell: UICollectionViewCell {
    
    @IBOutlet var showVideo: UIImageView!
    var videoURL: URL?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 13
        playerLayer?.frame = showVideo.bounds
        setupVideoPlayer()
        
    }

    func updateVideo(with video: Video) {
        showVideo.image = video.showImage
        self.videoURL = video.videoURL
        setupVideoPlayer()
    }
    
    func setupVideoPlayer() {
        guard let videoURL = videoURL else { return }
        
        // Remove existing player layer if any
        playerLayer?.removeFromSuperlayer()
        
        // Create AVPlayer
        player = AVPlayer(url: videoURL)
        
        // Create AVPlayerLayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        
        // Add player layer to showVideo's layer
        if let playerLayer = playerLayer {
            showVideo.layer.addSublayer(playerLayer)
            playerLayer.frame = showVideo.bounds
            
            // Start playing
            player?.play()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update player layer frame when cell is laid out
        playerLayer?.frame = showVideo.bounds
    }
    
    deinit {
        // Clean up
        player?.pause()
        player = nil
    }
}
