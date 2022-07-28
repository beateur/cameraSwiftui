//
//  File.swift
//  
//
//  Created by Bilel Hattay on 27/07/2022.
//

import SwiftUI
import UIKit
import PhotosUI

struct GalleryPickerView: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration
    let completion: (PHFetchResult<PHAsset>)  -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<GalleryPickerView>) -> PHPickerViewController {
        let pickerController = PHPickerViewController(configuration: configuration)
        pickerController.delegate = context.coordinator
        return pickerController
    }
 
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<GalleryPickerView>) {
 
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: PHPickerViewControllerDelegate {
        let parent: GalleryPickerView
        
        init(_ parent: GalleryPickerView) {
            self.parent = parent
        }
        
        func picker(_: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            let identifiers: [String] = results.compactMap(\.assetIdentifier)
            
            let fetchoptions = PHFetchOptions()
            fetchoptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchoptions.includeHiddenAssets = false
            let fetchresults = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: fetchoptions)

            print("fetchresults: \(fetchresults.firstObject)")
            parent.completion(fetchresults)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        
        
//        public func extractPreviewData(asset: PHAsset, completion: @escaping(UIImage?, AVAsset?)->()) {
//             let manager = PHCachingImageManager()
//
//             if asset.mediaType == .video {
//                 let videoManager = PHVideoRequestOptions()
//                 videoManager.deliveryMode = .highQualityFormat
//
//                 manager.requestAVAsset(forVideo: asset, options: videoManager) { videoAsset, _, _ in
//                     guard let videoUrl = videoAsset else {return}
//
//                     DispatchQueue.main.async {
//                         completion(nil, videoUrl)
//                     }
//                 }
//             }
//
//             if asset.mediaType == .image {
//                 ImagePickerViewModel.shared.getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize) { (image) in
//                     DispatchQueue.main.async {
//                         completion(image, nil)
//                     }
//                 }
//             }
//         }
    }
}
