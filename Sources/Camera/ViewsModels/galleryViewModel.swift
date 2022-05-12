//
//  galleryViewModel.swift
//  CameraViews
//
//  Created by Bilel Hattay on 10/05/2022.
//

import SwiftUI
import Photos
 
class ImagePickerViewModel: NSObject, ObservableObject {
    @Published var showPickerList = false
    @Published var showPickerMosaïque = false
    @Published var libraryStatus = PHLibraryStatus.denied
    @Published var fetchedElements = [Asset]()
    @Published var allPhotos:PHFetchResult<PHAsset>!
    
    
    func initPicker() {
        setup()
        fetchElements()
    }
    
    func fetchElements() {
        if fetchedElements.isEmpty {
            fetchAssets()
        }
    }
    
    func openPickerList() {
        initPicker()
        withAnimation {
            showPickerList.toggle()
        }
    }
    
    func openPickerMosaïque() {
        setup()
        withAnimation {
            showPickerMosaïque.toggle()
        }
    }
    
    func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.includeHiddenAssets = false
        
        let fetchresult = PHAsset.fetchAssets(with: options)
        allPhotos = fetchresult
        fetchresult.enumerateObjects { asset, index, _ in
            self.getContentFromAsset(asset: asset) { picture in
                self.fetchedElements.append(Asset(asset: asset, image: picture))
            }
        }
    }
    
    func getContentFromAsset(asset: PHAsset, completion: @escaping(UIImage)->()) {
        let manager = PHCachingImageManager()
        manager.allowsCachingHighQualityImages = true
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        let size = CGSize(width: UIScreen.main.bounds.size.height * 0.22, height: UIScreen.main.bounds.size.height * 0.22)
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
            guard let resizedImage = image else { return }
            
            completion(resizedImage)
        }
    }
    
    func setup() {
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
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let _ = allPhotos else { return }

        if let updates = changeInstance.changeDetails(for: allPhotos) {
            let updatedPhotos = updates.fetchResultAfterChanges

            updatedPhotos.enumerateObjects { asset, index, _ in
                if !self.allPhotos.contains(asset) {
                    self.getContentFromAsset(asset: asset) { image in
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
