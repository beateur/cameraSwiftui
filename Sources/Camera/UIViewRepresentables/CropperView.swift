//
//  File.swift
//  
//
//  Created by Bilel Hattay on 20/06/2022.
//

import SwiftUI
import Mantis

class ImageEditorCoordinator: NSObject, CropViewControllerDelegate {
    @Binding var image: UIImage?
    @Binding var isShowing: Bool
    
    init(image: Binding<UIImage?>, isShowing: Binding<Bool>) {
        _image = image
        _isShowing = isShowing
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
        self.image = cropped
        isShowing = false
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        isShowing = false
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        isShowing = false
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
    
    var frame: CGSize
    
    func makeCoordinator() -> ImageEditorCoordinator {
        return ImageEditorCoordinator(image: $image, isShowing: $isShowing)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<imageEditor>) -> Mantis.CropViewController {
        let Editor = Mantis.cropViewController(image: image!)
        Editor.delegate = context.coordinator
        Editor.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: Double(frame.width / (frame.height)))
        return Editor
    }
}
