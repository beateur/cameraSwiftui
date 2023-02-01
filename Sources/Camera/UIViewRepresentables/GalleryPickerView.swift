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
    let completion: (_ image: UIImage?, _ asset: AVAsset?)  -> Void
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
            var _ = [Asset]()
            
            let identifiers: [String] = results.compactMap(\.assetIdentifier)

            let fetchoptions = PHFetchOptions()
            fetchoptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchoptions.includeHiddenAssets = false
            let fetchresults = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: fetchoptions)

            print("problem here \(fetchresults.count)")
            fetchresults.enumerateObjects { asset, index, _ in
                print("là dédans?")
                self.extractPreviewData(asset: asset) { image, video in
                    print("est )ce que ça passe là")
                    self.parent.completion(image, video)
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }        
        
        public func extractPreviewData(asset: PHAsset, completion: @escaping(UIImage?, AVAsset?)->()) {
            let manager = PHCachingImageManager()
            
            print("asset media type: \(asset.mediaType)")
            if asset.mediaType == .video {
                let videoManager = PHVideoRequestOptions()
                videoManager.deliveryMode = .highQualityFormat
                
                print("ici?")
                manager.requestAVAsset(forVideo: asset, options: videoManager) { videoAsset, _, _ in
                    guard let videoUrl = videoAsset else {return}
                    
                    DispatchQueue.main.async {
                        completion(nil, videoUrl)
                    }
                }
            }
            
            if asset.mediaType == .image {
                print("ou là?")

                ImagePickerViewModel.shared.getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize) { (image) in
                    print("ici c ça?")
                    DispatchQueue.main.async {
                        completion(image, nil)
                    }
                }
            }
        }
    }
}
