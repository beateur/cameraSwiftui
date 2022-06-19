//
//  cameraBalancer.swift
//  CameraViews
//
//  Created by Bilel Hattay on 07/05/2022.
//

import SwiftUI

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

    @StateObject var cameraInstanceModel = cameraInstanceViewModel.shared
    @StateObject var galleryViewModel = ImagePickerViewModel()
    
    @Binding var stopRunningCamera: Bool
    
    @EnvironmentObject var defaultCameraModel: defaultViewModel
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
                        cameraInstanceModel.maxDuration = 30
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
                performCompletion()
            }
            .onChange(of: cameraInstanceModel.photoCaptured) { newValue in
                performCompletion()
            }
            .onChange(of: galleryViewModel.selectedImage) { newValue in
                performCompletion()
            }
            .onChange(of: galleryViewModel.selectedVideo) { newValue in
                performCompletion()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: stopRunningCamera) { newValue in
            if newValue {
                DispatchQueue.global(qos: .userInitiated).async {
                    cameraInstanceModel.session.stopRunning()
                }
            }
        }
    }
    
    func performCompletion() {
        let image = galleryViewModel.selectedImage ?? cameraInstanceModel.photoCaptured
        let video = galleryViewModel.selectedVideo ?? cameraInstanceModel.previewAsset
        
        contentCompletion(image, video)
    }
}
