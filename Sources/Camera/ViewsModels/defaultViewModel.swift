//
//  defaultViewModel.swift
//  CameraViews
//
//  Created by Bilel Hattay on 05/05/2022.
//

import SwiftUI
import AVFoundation

#if !os(macOS)
@available(iOS 14, *)
public class defaultViewModel: ObservableObject {
    let RecordButton: AnyView
    let Filters: AnyView
    let dismissButtonView: AnyView
    let nextButtonView: AnyView
    
    public var preview: AnyView
    public var dismissCompletion: (()->())
    public var nextCompletion: (()->())
    
    @Published var galleryImage: UIImage? = nil
     
    public init(record: AnyView, filters: AnyView, dismissButtonView: AnyView, nextButtonView: AnyView, preview:  AnyView, dismissCompletion: @escaping()->(), nextCompletion: @escaping()->()) {
        self.RecordButton = record
        self.Filters = filters
        self.dismissButtonView = dismissButtonView
        self.nextButtonView = nextButtonView
        self.preview = preview
        self.dismissCompletion = dismissCompletion
        self.nextCompletion = nextCompletion

    }
    
    func dismiss(completion: @escaping()->()) {
        completion()
    }
    
    func emptydismiss() {
        
    }
    
    @ViewBuilder func entete(dismiss: @escaping()->(), next: @escaping()->()?) -> some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                dismissButtonView
            }
            Spacer()
//            Button(action: {
//                next()
//            }) {
//                nextButtonView
//            }
        }
        .padding()
    }
    
    @ViewBuilder func flashElement(disabled: Bool, flashmode: AVCaptureDevice.FlashMode, perform: @escaping()->()) -> some View {
        Button {
            perform()
        } label: {
            switch flashmode {
            case .on:
                Image(systemName: "bolt.fill")
            case .off:
                Image(systemName: "bolt.slash.fill")
            case .auto:
                Image(systemName: "bolt")
            @unknown default:
                Image(systemName: "bolt.fill")
            }
        }
        .disabled(disabled)
    }
    
    @ViewBuilder func cameraInversion(perform: @escaping()->()) -> some View {
        Button {
            perform()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
        }
    }
    
    @ViewBuilder func recordButton(isRecording: Bool) -> some View {
        ZStack {
            Circle().fill(LinearGradient(colors: [Color.red, Color.red.opacity(0.7), Color.red.opacity(0.5), Color.red.opacity(0.3)], startPoint: .center, endPoint: .top))
                .frame(width: 86, height: 86)
                .opacity(isRecording ? 1: 0)
            RecordButton
                .scaleEffect(isRecording ? 0.7: 1)
                .opacity(isRecording ? 0.5: 1)
        }
        
    }
    
    @ViewBuilder func filterButton() -> some View {
        Filters
    }
    
    @ViewBuilder func galleryButton() -> some View {
        if let image = galleryImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 13)
        } else {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 13)
        }
    }
}
#endif

