//
//  cameraBalancer.swift
//  CameraViews
//
//  Created by Bilel Hattay on 07/05/2022.
//

import SwiftUI
import PhotosUI

import Foundation
import AVFoundation

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

private extension EnvironmentValues {
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

public struct cameraBalancer: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @StateObject var cameraInstanceModel = cameraInstanceViewModel()
    @StateObject var galleryViewModel = ImagePickerViewModel()
    
    @Binding var stopRunningCamera: Bool
    
    @EnvironmentObject var defaultCameraModel: defaultViewModel
    
    
    // Add PHPicker configuration
    var pickerConfiguration: PHPickerConfiguration {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .any(of: [PHPickerFilter.images, PHPickerFilter.videos])
        config.selectionLimit = 1
        return config
    }
    
    public var contentCompletion: ((UIImage?, AVAsset?)->())

    public init(stopRunning: Binding<Bool>, contentCompletion: @escaping(UIImage?, AVAsset?)->()) {
        self.contentCompletion = contentCompletion
        self._stopRunningCamera = stopRunning
    }

    public var body: some View {
        ZStack {
            GeometryReader { reader in
                let size = reader.size
                
                // MARK: switch between camera's possibilities
                defaultCamera()
                    .padding(.bottom, safeAreaInsets.bottom)
                    .environmentObject(cameraInstanceModel)
                    .environmentObject(defaultCameraModel)
                    .environmentObject(galleryViewModel)
                    .onTapGesture(count: 2) {
                        cameraInstanceModel.switchCamera()
                    }
                    .onAppear {
//                        cameraInstanceModel.maxDuration = 30
                    }
                    .sheet(isPresented: $galleryViewModel.showGallery) {
                        GalleryPickerView(configuration: pickerConfiguration) { image, asset in

                            print("get here")
                            performGalleryCompletion(img: image, vid: asset)
                        }
                    }
                // MARK: progress bar
                cameraInstanceModel.progressBar(size: size)
                    
            }
            .onAppear(perform: cameraInstanceModel.checkPermission)
            .alert(isPresented: $cameraInstanceModel.alert) {
                Alert(title: Text("test title"))
            }
            .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
                if beginCountingGap {
                    gapOnDragTime += 0.01
                }
                cameraInstanceModel.makeProgression()
            }
            .onChange(of: cameraInstanceModel.previewAsset) { newValue in
                if newValue != nil {
                    performCompletion(type: 1)
                }
            }
            .onChange(of: cameraInstanceModel.photoCaptured) { newValue in
                if newValue != nil {
                    performCompletion(type: 0)
                }
            }
            .onChange(of: galleryViewModel.selectedImage) { newValue in
                if newValue != nil {
                    performCompletion(type: 0)
                }
            }
            .onChange(of: galleryViewModel.selectedVideo) { newValue in
                if newValue != nil {
                    performCompletion(type: 1)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: stopRunningCamera) { newValue in
            switch newValue {
            case true:
                print("newValue \(newValue)")
            case false:
                cameraInstanceModel.stoprunningsession()
            }
        }
    }
    
    func performGalleryCompletion(img: UIImage?, vid: AVAsset?) {
        print("arrived here")
        contentCompletion(img, vid)
        dismissAll()
    }
    
    func performCompletion(type: Int) {
        switch type {
        case 0:
            let image = galleryViewModel.selectedImage ?? cameraInstanceModel.photoCaptured
            dismissVideo()
            contentCompletion(image, nil)
        case 1:
            let video = galleryViewModel.selectedVideo ?? cameraInstanceModel.previewAsset
            dismissImage()
            contentCompletion(nil, video)
        default:
            print("defaulted")
            dismissVideo()
            dismissImage()
            contentCompletion(nil, nil)
        }
    }
    
    func dismissVideo() {
        galleryViewModel.selectedVideo = nil
        cameraInstanceModel.previewAsset = nil
    }
    
    func dismissImage() {
        galleryViewModel.selectedImage = nil
        cameraInstanceModel.photoCaptured = nil
    }
    
    func dismissAll() {
        dismissImage()
        dismissVideo()
    }
}
