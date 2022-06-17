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
    @Binding var shouldPlay: playingMode
    let player: AVPlayer
    let gravity: PlayerGravity
    let replay: Bool
    
    var onUpdate: ()->()
    var onEnd: (AVPlayer)->()
    public init(shouldPlay: Binding<playingMode>, asset: AVAsset, gravity: PlayerGravity, replay: Bool, onUpdate: @escaping()->(), onEnd: @escaping(AVPlayer)->()) {
        self._shouldPlay = shouldPlay
        self.gravity = gravity
        
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        self.player = player
        self.replay = replay
        self.onUpdate = onUpdate
        self.onEnd = onEnd
    }
    
    public var body: some View {
        let playerVM = PlayerViewModel.shared
        PlayerContainerView(player: player, gravity: gravity, replay: replay) {
            onUpdate()
        }
        .onAppear {
            playerVM.play(player: player)
        }
        .onDisappear {
            playerVM.stop(player: player)
        }
    }
}
