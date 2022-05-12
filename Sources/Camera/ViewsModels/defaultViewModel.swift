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
    
    var dismissCompletion: (()->())
    
    @Published var galleryImage: UIImage? = nil
     
    public init(record: AnyView, filters: AnyView, dismissCompletion: @escaping()->()) {
        self.RecordButton = record
        self.Filters = filters
        self.dismissCompletion = dismissCompletion
    }
    
    func dismiss(completion: @escaping()->()) {
        completion()
    }
    
    func emptydismiss() {
        
    }
    
    @ViewBuilder func entete(dismisselement: AnyView, nextelement: AnyView, dismiss: @escaping()->(), next: @escaping()->()?) -> some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                dismisselement
            }
            Spacer()
            Button(action: {
                next()
            }) {
                nextelement
            }
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
    
    @ViewBuilder func cameraInversion() -> some View {
        Button {
            
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
        }
    }
    
    @ViewBuilder func recordButton() -> some View {
        RecordButton
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

