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
        
        print("launched video: \rtime: \(currentItem?.currentTime())\rduration: \(currentItem?.duration)")
        if currentItem?.currentTime() == currentItem?.duration {
            currentItem?.seek(to: .zero, completionHandler: nil)
        }
        player.play()
    }
    
    public func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { _ in
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
