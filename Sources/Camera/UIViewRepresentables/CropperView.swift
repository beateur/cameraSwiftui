//
//  File.swift
//  
//
//  Created by Bilel Hattay on 20/06/2022.
//

import SwiftUI
import Mantis

class ImageEditorCoordinator: NSObject, CropViewControllerDelegate {
    let parent: imageEditor
    
    init(_ parent: imageEditor) {
        self.parent = parent
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
        parent.image = cropped
        parent.isShowing = false
        parent.isCropped = true
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        parent.isShowing = false
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        parent.isShowing = false
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        
    }
    
    func cropViewControllerWillDismiss(_ cropViewController: CropViewController) {
        
    }
    
    
}

struct imageEditor: UIViewControllerRepresentable {
    typealias Coordinator = ImageEditorCoordinator
    @Binding var image: UIImage?
    @Binding var isShowing: Bool
    @Binding var isCropped: Bool
    
    var ratio: Double
    
    func makeCoordinator() -> ImageEditorCoordinator {
        return ImageEditorCoordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<imageEditor>) -> Mantis.CropViewController {
        let Editor = Mantis.cropViewController(image: image!)
        Editor.delegate = context.coordinator
        Editor.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: ratio)
        return Editor
    }
}
