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
        PlayerContainerView(player: player, gravity: gravity) {
            onEditing(player)
        }
            .onAppear(perform: {
                PlayerViewModel.shared.play(player: player)
            })
            .onDisappear {
                PlayerViewModel.shared.pause(player: player)
            }
    }
}
