//
//  galleryViewModel.swift
//  CameraViews
//
//  Created by Bilel Hattay on 10/05/2022.
//

import SwiftUI
import Photos
import AVKit

public class ImagePickerViewModel: NSObject, ObservableObject {    
    @Published var showPickerList = false
    @Published public var showPickerMosaïque = false
    @Published var libraryStatus = PHLibraryStatus.denied
    @Published var fetchedElements = [Asset]()
    @Published var allPhotos: PHFetchResult<PHAsset>!
    
    @Published var selectedVideo: AVAsset!
    @Published var selectedImage: UIImage!
    @Published var showPreview = false
    
    @Published var tooMany = false
    
    public override init() {
        
    }
    
    public func initPicker(size: CGSize) {
        setup()
        fetchElements(size: size)

    }
    
   public func fetchElements(size: CGSize) {
        if fetchedElements.isEmpty {
            fetchAssets(size: size)
        }
    }
    
    func tapThumbnail(photo: Asset) {
        showPickerMosaïque = false
        showPickerList = false
        selectedImage = nil
        selectedVideo = nil
        extractPreviewData(asset: photo.asset)
        showPreview = true
    }
    
   public func openPickerList() {
        initPicker(size: ThumSize)
        withAnimation {
            showPickerList.toggle()
        }
    }
    
    public func openPickerMosaïque() {
        DispatchQueue.global().async {
            self.initPicker(size: MosaïqueSize)
        }
        
        withAnimation {
            showPickerMosaïque.toggle()
        }
    }
    
   public func dismissPreview() {
        showPreview = false
        selectedImage = nil
        selectedVideo = nil
    }
    
    public func dismissMosaïque() {
        showPickerMosaïque = false
        fetchedElements.removeAll()
    }
    
   public func dismissGalleryOverView() {
        if showPreview {
            dismissPreview()
        } else {
            dismissMosaïque()
        }
    }
    
    public func fetchAssets(size: CGSize) {
        tooMany = false
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.includeHiddenAssets = false
        
        let fetchresult = PHAsset.fetchAssets(with: options)
        
        if fetchresult.count > 200 {
            tooMany = true
            return
        }
        allPhotos = fetchresult

        fetchresult.enumerateObjects { asset, index, _ in
            self.getImageFromAsset(asset: asset, size: size) { picture in
                self.fetchedElements.append(Asset(asset: asset, image: picture))
            }
        }
    }
    
   public func getImageFromAsset(asset: PHAsset, size: CGSize, completion: @escaping(UIImage)->()) {
        let manager = PHCachingImageManager()
        manager.allowsCachingHighQualityImages = true
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        let size = CGSize(width: size.width, height: size.height)
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
            guard let resizedImage = image else { return }
            
            completion(resizedImage)
        }
    }
    
   public func extractPreviewData(asset: PHAsset) {
        let manager = PHCachingImageManager()
        
        if asset.mediaType == .video {
            let videoManager = PHVideoRequestOptions()
            videoManager.deliveryMode = .highQualityFormat
           
            manager.requestAVAsset(forVideo: asset, options: videoManager) { videoAsset, _, _ in
                guard let videoUrl = videoAsset else {return}
                
                DispatchQueue.main.async {
                    self.selectedVideo = videoUrl
                }
            }
        }
        
        if asset.mediaType == .image {
            getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize) { (image) in
                DispatchQueue.main.async {
                    self.selectedImage = image
                }
            }
        }
    }

    
   public func setup() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .notDetermined:
                DispatchQueue.main.async {
                    self.libraryStatus = .denied
                }
            case .restricted:
                DispatchQueue.main.async {
                    self.libraryStatus = .denied
                }
            case .denied:
                DispatchQueue.main.async {
                    self.libraryStatus = .denied
                }
            case .authorized:
                DispatchQueue.main.async {
                    self.libraryStatus = .authorized
                }
            case .limited:
                DispatchQueue.main.async {
                    self.libraryStatus = .limited
                }
            @unknown default:
                DispatchQueue.main.async {
                    self.libraryStatus = .denied
                }
            }
        }
        PHPhotoLibrary.shared().register(self)
    }
}

extension ImagePickerViewModel: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let _ = allPhotos else { return }

        if let updates = changeInstance.changeDetails(for: allPhotos) {
            let updatedPhotos = updates.fetchResultAfterChanges

            updatedPhotos.enumerateObjects { asset, index, _ in
                if !self.allPhotos.contains(asset) {
                    self.getImageFromAsset(asset: asset, size: ThumSize) { image in
                        DispatchQueue.main.async {
                            self.fetchedElements.append(Asset(asset: asset, image: image))
                        }
                    }
                }
            }

            allPhotos.enumerateObjects { asset, index, _ in
                if !updatedPhotos.contains(asset) {
                    DispatchQueue.main.async {
                        self.fetchedElements.removeAll() { (result) -> Bool in
                            return result.asset == asset
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.allPhotos = updatedPhotos
            }
        }
    }
}
