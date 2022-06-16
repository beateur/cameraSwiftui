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
    public init(asset: AVAsset, gravity: PlayerGravity, replay: Bool, onUpdate: @escaping()->(), onEnd: @escaping(AVPlayer)->()) {
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
        .onReceive(Timer.publish(every: 0.1, on: .current, in: .common).autoconnect()) { _ in
            if let item = player.currentItem {
                if player.currentTime().seconds >= item.duration.seconds {
                    print("entrer au bon endroit")
                    playerVM.stop(player: player)
                    onEnd(player)
                    
                }
            }
        }
        .onChange(of: shouldPlay) { newValue in
            switch newValue {
            case .play:
                playerVM.pause(player: player)
            case .pause:
                playerVM.play(player: player)
            case .stop:
                playerVM.stop(player: player)
            }
        }
    }
}
