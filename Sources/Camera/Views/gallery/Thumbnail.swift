//
//  ThumbnailView.swift
//  CameraViews
//
//  Created by Bilel Hattay on 10/05/2022.
//

import SwiftUI

struct ThumbnailView: View {
    var photo: Asset
    let size: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .cornerRadius(10)
            
            if photo.asset.mediaType == .video {
                Image(systemName: "video.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(6)
            }
        }
    }
}
