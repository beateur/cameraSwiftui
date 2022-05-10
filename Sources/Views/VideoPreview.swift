//
//  VideoPreview.swift
//  CameraViews
//
//  Created by Bilel Hattay on 07/05/2022.
//

import SwiftUI
import AVKit

struct VideoPreview: View {
    var url: URL

    var body: some View {
        GeometryReader { reader in
            let size = reader.size
            let player = AVPlayer(url: url)
            PlayerContainerView(player: player, gravity: .aspectFill, onEditingChanged: {
                PlayerViewModel.shared.loopVideo(videoPlayer: player)
            })
                .frame(width: size.width, height: size.height)
                .onAppear {
                    PlayerViewModel.shared.play(player: player)
                }
                .onDisappear {
                    PlayerViewModel.shared.pause(player: player)
                }            
        }
    }
}
