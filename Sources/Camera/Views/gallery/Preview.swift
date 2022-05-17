//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 13/05/2022.
//

import SwiftUI
import AVKit

struct contentPreview: View {
    let selectedVideo: AVAsset?
    let selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            if selectedImage != nil {
                
                let playerItem = AVPlayerItem(asset: selectedVideo!)
                let player = AVPlayer(playerItem: playerItem)

                PlayerContainerView(player: player, gravity: .aspectFill, onEditingChanged: {
                    PlayerViewModel.shared.loopVideo(videoPlayer: player)
                })
                    .onAppear(perform: {
                        PlayerViewModel.shared.play(player: player)
                    })
                    .onDisappear {
                        PlayerViewModel.shared.pause(player: player)
                    }
            }
            
            if selectedImage != nil {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
