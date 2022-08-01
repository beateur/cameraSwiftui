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
    @EnvironmentObject var defaultCameraModel: defaultViewModel
    @EnvironmentObject var cameraInstanceModel: cameraInstanceViewModel
    @EnvironmentObject var galleryViewModel: ImagePickerViewModel
    
    public init() {

    }
    
    public var body: some View {
        VStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.bottom)
                camera
                OverlayedComponents
            }
        }
    }    
    
    private var entete: some View {
        defaultCameraModel.entete {
            defaultCameraModel.dismiss {
                if cameraInstanceModel.showPreview {
                    cameraInstanceModel.dismissPreview()
                }
                else if galleryViewModel.showPickerMosaïque || galleryViewModel.showPreview {
                    print("dismmissed good")
                    galleryViewModel.dismissGalleryOverView()
                }
                else {
                    print("dismmissed bad")
                    defaultCameraModel.dismissCompletion()
                }
            }
        } next: {
            print("nexted")
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
        .padding(.vertical)
    }
    
    private var bottomComponents: some View {
        VStack {
            ThumbList()
                .environmentObject(galleryViewModel)
            bardesButtons
        }
    }
    
    private var bardesButtons: some View {
        HStack {
            defaultCameraModel.galleryButton()
                .padding(7)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(36)
                .scaleEffect(2)
                .onTapGesture {
                    galleryViewModel.openGallery()
//                    galleryViewModel.openPickerMosaïque()
                }
                .padding(.leading, 27)
            Spacer()
            defaultCameraModel.recordButton(isRecording: cameraInstanceModel.isRecording)
            // foutre la gesture ailleurs
                .gesture(
                    DragGesture(minimumDistance: .zero, coordinateSpace: .global)
                    .onEnded { _ in
                        onEndedGesture()
                    }
                    .onChanged { _ in
                        onChangedGesture()
                    }
                )
                .padding(.trailing, 50)
            Spacer()
//            defaultCameraModel.filterButton()
//                .padding(.trailing, 40)
        }
    }
    
    func onEndedGesture() {
        beginCountingGap = false
        switch cameraInstanceModel.capturemode {
        case .video:
            cameraInstanceModel.stopRecording()
            cameraInstanceModel.capturemode = .photo
        case .photo:
            if gapOnDragTime <= 0.65 {
                cameraInstanceModel.takePhoto()
            }
        }
        gapOnDragTime -= gapOnDragTime
    }
    
    func onChangedGesture() {
        beginCountingGap = true
        if !cameraInstanceModel.isRecording {
            if gapOnDragTime > 0.65 {
                cameraInstanceModel.capturemode = .video
                cameraInstanceModel.startRecording()
            }
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
            .scaleEffect(2)
            Spacer()
            defaultCameraModel.cameraInversion(perform: {
                cameraInstanceModel.switchCamera()
            })
            .padding(.trailing)
            .scaleEffect(2)
        }
        .foregroundColor(.white)
    }
}
#endif

