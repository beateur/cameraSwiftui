//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 09/06/2022.
//

import SwiftUI
import AVFoundation

public struct PlayerContainerViewCaller: View {
    let player: AVPlayer
    let gravity: PlayerGravity
    
    var onEditing: (AVPlayer)->()
    public init(asset: AVAsset, gravity: PlayerGravity, onedition: @escaping(AVPlayer)->()) {
        self.gravity = gravity
        
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        self.player = player
        self.onEditing = onedition
    }
    
    public var body: some View {
        let playerVM = PlayerViewModel.shared
        PlayerContainerView(player: player, gravity: gravity) {
            onEditing(player)
        }
        .onReceive(Timer.publish(every: 0.1, on: .current, in: .common).autoconnect()) { _ in
            if let item = player.currentItem {
                if player.currentTime() >= item.duration {
                    playerVM.pause(player: player)
                    onEditing(player)
                }
            }
        }
        .onAppear(perform: {
            playerVM.play(player: player)
        })
        .onDisappear {
            playerVM.pause(player: player)
        }
    }
}
