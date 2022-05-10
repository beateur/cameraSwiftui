//
//  defaultCamera.swift
//  CameraViews
//
//  Created by Bilel Hattay on 05/05/2022.
//

import SwiftUI

#if !os(macOS)
@available(iOS 14, *)
public struct defaultCamera: View {
    @StateObject var defaultCameraModel = defaultViewModel(record:  AnyView(Circle().fill(Color.blue).frame(width: 72, height: 72)), filters: AnyView(Rectangle().fill(Color.white).frame(width: 18, height: 40)))
    @EnvironmentObject var cameraInstanceModel: cameraInstanceViewModel
    
    public var body: some View {
        VStack {
            entete
            ZStack {
                Color.black
                camera
                OverlayedComponents
                
                if cameraInstanceModel.showPreview {
                    if let url = cameraInstanceModel.previewURL {
                        VideoPreview(url: url)
                            .animation(.easeInOut, value: cameraInstanceModel.showPreview)
                    } else {
                        if let previewImage = cameraInstanceModel.photoCaptured {
                            PhotoPreview(photoPreview: previewImage)
                        }
                    }
                }
            }
        }
    }
    
    private var entete: some View {
        defaultCameraModel.entete(dismisselement: AnyView(Image(systemName: "xmark").resizable().frame(width: 15, height: 15)), nextelement: AnyView(Image(systemName: "arrow.right").resizable().frame(width: 30, height: 10))) {
            defaultCameraModel.dismiss {
                if cameraInstanceModel.showPreview || cameraInstanceModel.photoCaptured != nil {
                    cameraInstanceModel.dismissPreview()
                } else {
//                    defaultCameraModel.dismissCompletion
                }
            }
        } next: {

        }
    }
    
    private var camera: some View {
        GeometryReader { reader in
            let size = reader.size
            
            cameraModelPreview(size: size)
                .environmentObject(cameraInstanceModel)
        }
    }
    
    private var OverlayedComponents: some View {
        VStack {
            topComponents
            Spacer()
            bottomComponents
        }
        .padding()
    }
    
    private var bottomComponents: some View {
        HStack {
            defaultCameraModel.galleryButton()
                .padding(.leading, 40)
                .scaleEffect(1.2)
            Spacer()
            defaultCameraModel.recordButton()
                .gesture(
                    DragGesture(minimumDistance: .zero, coordinateSpace: .global)
                    .onEnded { _ in
                        beginCountingGap = false
                        switch cameraInstanceModel.capturemode {
                        case .video:
                            cameraInstanceModel.stopRecording()
                            print("\(cameraInstanceModel.capturemode) et \(gapOnDragTime)")
                            cameraInstanceModel.capturemode = .photo
                        case .photo:
                            if gapOnDragTime <= 2 {
                                cameraInstanceModel.takePhoto()
                            }
                        }
                        gapOnDragTime -= gapOnDragTime
                    }
                    .onChanged { _ in
                        print("testned")
                        beginCountingGap = true
                        if !cameraInstanceModel.isRecording {
                            if gapOnDragTime > 2 {
                                cameraInstanceModel.capturemode = .video
                                cameraInstanceModel.startRecording()
                            }
                        }
                        
                    }
                )
            Spacer()
            defaultCameraModel.filterButton()
                .padding(.trailing, 40)
        }
    }
    
    private var topComponents: some View {
        HStack {
            Spacer()
            defaultCameraModel.flashElement(disabled: cameraInstanceModel.isRecording, flashmode: cameraInstanceModel.flashMode, perform: {
                cameraInstanceModel.switchFlash()
            })
                .padding(.leading)
                .padding(.leading)
                .scaleEffect(1.2)
            Spacer()
            defaultCameraModel.cameraInversion()
                .padding(.trailing)
                .scaleEffect(1.2)
        }
        .foregroundColor(.white)
    }
}
#endif

