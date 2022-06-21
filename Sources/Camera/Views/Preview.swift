//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 13/05/2022.
//

import SwiftUI
import AVKit

public struct contentPreview: View {
    let isCroppable: Bool
    let selectedVideo: AVAsset?
    @Binding var selectedImage: UIImage?
    @State var needCrop = false
    
    public init (isCroppable: Bool, selectedVideo: AVAsset?, selectedImage: Binding<UIImage?>) {
        self.isCroppable = isCroppable
        self.selectedVideo = selectedVideo
        self._selectedImage = selectedImage
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
                            if isCroppable {
                                if needCrop {
                                    imageEditor(image: $selectedImage, isShowing: $needCrop, frame: CGSize(width: 4, height: 3))
                                        .frame(width: size.width, height: size.height)
                                } else {
                                    if selectedImage!.size.width < selectedImage!.size.height {
                                        Image(uiImage: selectedImage!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: size.height)
                                    } else {
                                        Image(uiImage: selectedImage!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: size.height)
                                    }
                                    
                                    Button {
                                        needCrop.toggle()
                                    } label: {
                                        Image(systemName: "crop")
                                            .font(.system(size: 26))
                                    }
                                    .padding()
                                    .background(Color(hex: 0xF9F9F9))
                                    .cornerRadius(15)
                                }
                                
                                
                            } else {
                                Image(uiImage: selectedImage!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.width, height: size.height)
                                    .clipped()
                            }
                        }
                        .frame(width: size.width)
                        .background(Color(hex: 0x0))
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

