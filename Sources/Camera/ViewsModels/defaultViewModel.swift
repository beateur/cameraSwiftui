//
//  File.swift
//  
//
//  Created by Bilel Hattay on 05/05/2022.
//

import SwiftUI

#if !os(macOS)
@available(iOS 14, *)
public class defaultViewModel: ObservableObject {
    let manager = defaultManager.instance
    let RecordButton: AnyView
    let Filters: AnyView
    
    @Published var galleryImage: UIImage? = nil
     
    init(record: AnyView, filters: AnyView) {
        self.RecordButton = record
        self.Filters = filters
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
    }
    
    @ViewBuilder func flashElement() -> some View {
        Button {
            self.manager.toggleFlash()
        } label: {
            if manager.flashisActive {
                Image(systemName: "bolt.fill")
            } else {
                Image(systemName: "bolt.slash.fill")
            }
        }
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
        } else {
            Image(systemName: "photo")
        }
    }
}
#endif

