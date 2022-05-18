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
            GeometryReader { reader in
                let size = reader.size
                
                Color.white
                    .frame(width: size.width, height: size.height)
                
                VStack {
                    Spacer()
                    if selectedVideo != nil {
                        
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
                    Spacer()
                }
            }
            
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
