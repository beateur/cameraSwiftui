//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 13/05/2022.
//

import SwiftUI
import AVKit

public struct contentPreview: View {
    let selectedVideo: AVAsset?
    let selectedImage: UIImage?
    
    public init (selectedVideo: AVAsset?, selectedImage: UIImage?) {
        print("initied: \(selectedVideo) \(selectedImage)")
        self.selectedVideo = selectedVideo
        self.selectedImage = selectedImage
    }
    
    public var body: some View {
        ZStack {
            GeometryReader { reader in
                let size = reader.size
                
                 Color(hex: 0xFFFFFF)
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
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .clipped()
                    }
                    Spacer()
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

