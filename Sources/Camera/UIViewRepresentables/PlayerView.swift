//
//  PlayerView.swift
//  CameraViews
//
//  Created by Bilel Hattay on 09/05/2022.
//

import Foundation
import SwiftUI
import AVFoundation
import AVKit

struct PlayerContainerView: UIViewRepresentable {
    typealias UIViewType = PlayerView
    
    let player: AVPlayer
    let gravity: PlayerGravity
    let replay: Bool
    let onEditingChanged: ()->()
    
    init(player: AVPlayer, gravity: PlayerGravity, replay: Bool, onEditingChanged: @escaping()->()) {
        self.player = player
        self.gravity = gravity
        self.replay = replay
        self.onEditingChanged = onEditingChanged
    }
    
    func makeUIView(context: Context) -> PlayerView {
        return PlayerView(player: player, gravity: gravity)
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            onEditingChanged()
        }
    }
}
