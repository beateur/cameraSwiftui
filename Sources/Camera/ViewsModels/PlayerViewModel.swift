//
//  PlayerViewModel.swift
//  CameraViews
//
//  Created by Bilel Hattay on 09/05/2022.
//

import Foundation
import AVFoundation

class PlayerViewModel: ObservableObject {
    static let shared = PlayerViewModel()
    var observer: NSObjectProtocol?
    
    func play(player: AVPlayer) {
        let currentItem = player.currentItem
        if currentItem?.currentTime() == currentItem?.duration {
            currentItem?.seek(to: .zero, completionHandler: nil)
        }
        player.play()
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            videoPlayer.seek(to: .zero)
            videoPlayer.play()
        }
    }
    
    func pause(player: AVPlayer) {
        player.pause()
        if let _ = observer {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
