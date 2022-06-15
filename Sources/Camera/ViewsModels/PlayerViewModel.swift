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
    private var observer: NSObjectProtocol?
    
    public func play(player: AVPlayer) {
        let currentItem = player.currentItem
        if currentItem?.currentTime() == currentItem?.duration {
            currentItem?.seek(to: .zero, completionHandler: nil)
        }
        player.play()
    }
    
    public func loopVideo(videoPlayer: AVPlayer) {
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { _ in
            self.play(player: videoPlayer)
        }
    }
    
    public func pause(player: AVPlayer) {
        player.pause()
        if let _ = observer {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
