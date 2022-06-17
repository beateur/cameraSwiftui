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
        player.play()
    }
    
    public func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            self.stop(player: videoPlayer)
            self.play(player: videoPlayer)
        }
    }
    
    public func pause(player: AVPlayer) {
        player.pause()
    }
    
    public func stop(player: AVPlayer) {
        player.pause()
        player.seek(to: CMTime.init(seconds: 0, preferredTimescale: 1))
    }
}
