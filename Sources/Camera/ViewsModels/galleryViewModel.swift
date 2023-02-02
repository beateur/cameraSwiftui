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
    static let shared = ImagePickerViewModel()
    
    @Published public var showGallery = false
    @Published var showPickerList = false
    @Published public var showPickerMosaïque = false
    @Published var libraryStatus = PHLibraryStatus.denied
    @Published var fetchedElements = [Asset]()
    @Published var allPhotos: PHFetchResult<PHAsset>!
    
    @Published var selectedVideo: AVAsset!
    @Published var selectedImage: UIImage!
    @Published var showPreview = false
        
    public override init() {
        
    }
    
    public func initPicker(size: CGSize) {
        setup()
        fetchElements(size: size)
    }
    
    public func openGallery() {
        showGallery = true
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
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.includeHiddenAssets = false
        
        let fetchresult = PHAsset.fetchAssets(with: options)

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
        options.deliveryMode = .opportunistic
       options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        let size = CGSize(width: size.width, height: size.height)
       print("ça passe là")
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, infos in
            
            if let infos = infos {
                if let error = infos[PHImageErrorKey] as? NSError {
                    NSLog("Nil image error = \(error.localizedDescription)")
                }
                for info in infos {
                    print("des infos randoms: \(info.key) --> \(info.value)")
                }
            }
            guard let resizedImage = image else { print("fail guard let"); return }
            print("ça réussi là") 
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
