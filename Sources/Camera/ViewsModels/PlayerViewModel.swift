//
//  PlayerViewModel.swift
//  CameraViews
//
//  Created by Bilel Hattay on 09/05/2022.
//

import Foundation
import AVFoundation

public class PlayerViewModel: ObservableObject {
    public static let shared = PlayerViewModel()
    
    public func play(player: AVPlayer) {
        let currentItem = player.currentItem
        if currentItem?.currentTime() == currentItem?.duration {
            currentItem?.seek(to: .zero, completionHandler: nil)
        }
        
        print("play video")
        player.play()
    }
    
    public func loopVideo(videoPlayer: AVPlayer) {
        videoPlayer.seek(to: CMTime.init(seconds: 0, preferredTimescale: 1))
        self.play(player: videoPlayer)
    }
    
    public func pause(player: AVPlayer) {
        player.pause()
    }

    public func stopVideo(player: AVPlayer) {
        player.pause()
        player.seek(to: CMTime.init(seconds: 0, preferredTimescale: 1))
    }
}
