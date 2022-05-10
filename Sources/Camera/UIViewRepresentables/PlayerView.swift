//
//  PlayerView.swift
//  CameraViews
//
//  Created by Bilel Hattay on 09/05/2022.
//

import Foundation
import SwiftUI
import AVFoundation

final class PlayerContainerView: UIViewRepresentable {
    typealias UIViewType = PlayerView
    
    let player: AVPlayer
    let gravity: PlayerGravity
    let onEditingChanged: ()->()
    
    init(player: AVPlayer, gravity: PlayerGravity, onEditingChanged: @escaping()->()) {
        self.player = player
        self.gravity = gravity
        self.onEditingChanged = onEditingChanged
    }
    
    func makeUIView(context: Context) -> PlayerView {
        return PlayerView(player: player, gravity: gravity)
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        onEditingChanged()
    }
}
