//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 13/05/2022.
//

import SwiftUI
import AVKit

public struct contentPreview: View {
    let ratio: Double
    let isCroppable: Bool
    let gravity: PlayerGravity
    let selectedVideo: AVAsset?
    @Binding var selectedImage: UIImage?
    @State var needCrop = false
    @State var isCrop = false
    @State var videoPlaying = true

    public init (ratio: CGFloat, gravity: PlayerGravity, isCroppable: Bool, selectedVideo: AVAsset?, selectedImage: Binding<UIImage?>) {
        self.ratio = ratio
        self.gravity = gravity
        self.isCroppable = isCroppable
        self.selectedVideo = selectedVideo
        self._selectedImage = selectedImage
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { reader in
                let size = reader.size
                
                 Color(hex: 0xFFFFFF)
                    .frame(width: size.width, height: size.height)

                VStack {
                    Spacer()
                    if selectedVideo != nil {
                        ZStack {
                            PlayerContainerViewCaller(asset: selectedVideo!, gravity: .aspectFill, play: true) { _ in
                                
                            }
                        }
                    }
                    
                    if selectedImage != nil {
                        showImage(size: size)
                    }
                    Spacer()
                }
            }
            
            if isCroppable && selectedImage != nil && !isCrop && !needCrop {
                Button {
                    needCrop.toggle()
                } label: {
                    Image(systemName: "crop")
                        .font(.system(size: 13))
                        .padding()
                        .background(Color(hex: 0xF9F9F9).opacity(0.65))
                }
                .cornerRadius(15)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    @ViewBuilder func showImage(size: CGSize) -> some View {
        ZStack {
            if isCroppable {
                if needCrop {
                    let sizecrop = ratio == 1.0 ? CGSize(width: 4, height: 4) : CGSize(width: 4, height: 3)
                    imageEditor(image: $selectedImage, isShowing: $needCrop, isCropped: $isCrop, frame: sizecrop)
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

