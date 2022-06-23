//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 09/06/2022.
//

import SwiftUI
import AVFoundation

public enum playingMode {
    case play, pause, stop
}

public struct PlayerContainerViewCaller: View {
    let player: AVPlayer
    let gravity: PlayerGravity
    let replay: Bool
    
    var onUpdate: (AVPlayer)->()
    public init(asset: AVAsset, gravity: PlayerGravity, replay: Bool, onUpdate: @escaping(AVPlayer)->()) {
        self.gravity = gravity
        
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        self.player = player
        self.replay = replay
        self.onUpdate = onUpdate
    }
    
    public var body: some View {
        let playerVM = PlayerViewModel.shared
        PlayerContainerView(player: player, gravity: gravity, replay: replay) {
            onUpdate(player)
        }
        .onAppear {
            playerVM.play(player: player)
        }
        .onDisappear {
            print("disappeared video")
            playerVM.stop(player: player)
        }
    }
}
