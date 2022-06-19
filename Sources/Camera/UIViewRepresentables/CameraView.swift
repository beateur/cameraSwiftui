//
//  CameraView.swift
//  CameraViews
//
//  Created by Bilel Hattay on 09/05/2022.
//

import SwiftUI
import UIKit
import Foundation
import AVFoundation

struct cameraModelPreview: UIViewRepresentable {
    @EnvironmentObject var cameraModel: cameraInstanceViewModel
    var size: CGSize
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        
        DispatchQueue.global(qos: .userInitiated).async {
            cameraModel.preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
            cameraModel.preview.frame.size = size
            cameraModel.preview.videoGravity = .resizeAspectFill
            cameraModel.session.startRunning()
        }
        
        DispatchQueue.main.async {
            view.layer.addSublayer(cameraModel.preview)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
}
