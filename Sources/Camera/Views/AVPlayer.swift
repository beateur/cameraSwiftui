//
//  PlayerViewModel.swift
//  CameraViews
//
//  Created by Bilel Hattay on 09/05/2022.
//

import AVFoundation
import UIKit

class PlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    let gravity: PlayerGravity
    
    init(player: AVPlayer, gravity: PlayerGravity) {
        self.gravity = gravity
        super.init(frame: .zero)
        self.player = player
        self.backgroundColor = .black
        setupLayer()
        NotificationCenter.default.addObserver(self, selector: #selector(stopVideo), name:
        NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func stopVideo() {
        if let player = player {
            player.pause()
            player.seek(to: CMTime.init(seconds: 0, preferredTimescale: 1))
        }
    }
    
    func setupLayer() {
        switch gravity {
    
        case .aspectFill:
            playerLayer.contentsGravity = .resizeAspectFill
            playerLayer.videoGravity = .resizeAspectFill
            
        case .resize:
            playerLayer.contentsGravity = .resize
            playerLayer.videoGravity = .resize
            
        }
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
