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
        
        DispatchQueue.global().async {
            let preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
            preview.frame.size = size
            preview.videoGravity = .resizeAspectFill
            
            DispatchQueue.main.async {
                cameraModel.preview = preview

                DispatchQueue.global(qos: .userInitiated).async {
                    view.layer.addSublayer(cameraModel.preview)
                    cameraModel.session.startRunning()
                }
            }
//            cameraModel.preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
//            cameraModel.preview.frame.size = size
//            cameraModel.preview.videoGravity = .resizeAspectFill
//
//            view.layer.addSublayer(cameraModel.preview)
//            print("startrunning make UIview")
//            cameraModel.session.startRunning()
            
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
}
