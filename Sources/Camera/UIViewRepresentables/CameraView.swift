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
        let preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
       
        preview.frame.size = size
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cameraModel.startrunningsession()
        }

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
