//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 13/05/2022.
//

import SwiftUI
import AVKit

struct contentPreview: View {
    @EnvironmentObject var galleryPicker: ImagePickerViewModel

    var body: some View {
        ZStack {
            if galleryPicker.selectedVideo != nil {
                
                let playerItem = AVPlayerItem(asset: galleryPicker.selectedVideo)
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
            
            if galleryPicker.selectedImage != nil {
                Image(uiImage: galleryPicker.selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
