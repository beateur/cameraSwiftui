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
    @State var selectedImage: UIImage?
    @State var needCrop = false
    
    public init (selectedVideo: AVAsset?, selectedImage: UIImage?) {
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

                        PlayerContainerView(player: player, gravity: .aspectFill, replay: true) {

                        }
                        .onAppear {
                            PlayerViewModel.shared.play(player: player)
                        }
                        .onDisappear {
                            PlayerViewModel.shared.pause(player: player)
                        }
                    }
                    
                    if selectedImage != nil {
                        ZStack(alignment: .bottomLeading) {
                            
                            if needCrop {
                                imageEditor(image: $selectedImage, isShowing: $needCrop, frame: CGSize(width: 4, height: 3))
                            } else {
                                if selectedImage!.size.width < selectedImage!.size.height {
                                    Image(uiImage: selectedImage!)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: size.height)
                                        .clipped()
                                } else {
                                    Image(uiImage: selectedImage!)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: size.height)
                                        .clipped()
                                }
                                
                            }

                            Button {
                                needCrop.toggle()
                            } label: {
                                Circle().fill(Color.red).frame(width: 48, height: 48)
                            }

                        }
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

