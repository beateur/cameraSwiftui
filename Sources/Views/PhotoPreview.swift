//
//  PhotoPreview.swift
//  CameraViews
//
//  Created by Bilel Hattay on 10/05/2022.
//

import SwiftUI

struct PhotoPreview: View {
    var photoPreview: UIImage

    var body: some View {
        GeometryReader { reader in
            let size = reader.size
            
            Image(uiImage: photoPreview)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
        }
    }
}
