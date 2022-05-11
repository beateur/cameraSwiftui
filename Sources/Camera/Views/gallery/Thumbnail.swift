//
//  ThumbnailView.swift
//  CameraViews
//
//  Created by Bilel Hattay on 10/05/2022.
//

import SwiftUI

struct ThumbnailView: View {
    var photo: Asset
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.size.height * 0.22, height: UIScreen.main.bounds.size.height * 0.22)
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
