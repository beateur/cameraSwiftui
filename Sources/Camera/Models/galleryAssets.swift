//
//  galleryAssets.swift
//  CameraViews
//
//  Created by Bilel Hattay on 10/05/2022.
//

import SwiftUI
import Photos

struct Asset {
    var asset: PHAsset
    var image: UIImage
}

extension Asset: Hashable {
    
}
