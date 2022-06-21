//
//  InstanceViewModel.swift
//  CameraViews
//
//  Created by Bilel Hattay on 05/05/2022.
//

import SwiftUI
import UIKit
import Foundation
import AVFoundation

class cameraInstanceViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    static let shared = cameraInstanceViewModel()
    
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var photoOutput = AVCapturePhotoOutput()
    @Published var movieOutput = AVCaptureMovieFileOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var capturemode: captureMode = .photo
    
    var cameraPosition: AVCaptureDevice.Position = .back
    var cameraInput: AVCaptureInput!
    
    // MARK: VIDEO RECORDER PROPERTIES
    @Published var isRecording = false
//    @Published var recordedUrls = [URL]()
    @Published var previewAsset: AVAsset?
    @Published var showPreview = false
    
    // MARK: PROGRESS BAR
    @Published var recordDuration: CGFloat = 0
    var progressColor: Color? = nil
    var backgroundProgressColor: Color? = nil
    var progressbarHeight: CGFloat? = nil
    var maxDuration: CGFloat? = nil
    
    // MARK: PHOTO PROCESSING
    @Published var photoCaptured: UIImage?
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    self.setup()
                    return
                }
            }
        case .restricted:
            self.alert = true
            return
        case .denied:
            self.alert = true
            return
        case .authorized:
            setup()
            return
        @unknown default:
            return
        }
    }
    
    func switchCamera() {
        if session.inputs.isEmpty {
           return
        }
        session.removeInput(cameraInput)
        
        switch cameraPosition {
        case .unspecified, .front:
            cameraPosition = .back
        case .back:
            cameraPosition = .front
        @unknown default:
            cameraPosition = .back
        }
        if let newCam = createDevice() {
            do {
                let newInput = try AVCaptureDeviceInput(device: newCam)
                cameraInput = newInput
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                    adjustVideoMirror()
                }
            } catch {
                // handle plus tard
            }
        }
    }
    
    func setup() {
        do {
            self.session.beginConfiguration()


            if let cameradevice = createDevice() {
                let camerainput = try AVCaptureDeviceInput(device: cameradevice)
                cameraInput = camerainput
                let audiodevice = AVCaptureDevice.default(for: .audio)
                let audioinput = try AVCaptureDeviceInput(device: audiodevice!)
                                        
                if self.session.canAddInput(camerainput) && self.session.canAddInput(audioinput) {
                    self.session.addInput(camerainput)
                    self.session.addInput(audioinput)
                }
                
                if self.session.canAddOutput(photoOutput) {
                    self.session.addOutput(photoOutput)
                    photoOutput.isHighResolutionCaptureEnabled = true
                }
                
                if self.session.canAddOutput(self.movieOutput) {
                    self.session.addOutput(self.movieOutput)
                }
            }
            
            self.session.commitConfiguration()
            
        } catch {

        }
    }
    
    private func adjustVideoMirror(){
        
        if let conn = movieOutput.connection(with: .video){
            conn.isVideoMirrored = cameraPosition == .front
        }
        
        if let conn = photoOutput.connection(with: .video){
            conn.isVideoMirrored = cameraPosition == .front
        }
    }
    
    func createDevice() -> AVCaptureDevice? {
        if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: cameraPosition) {
            return dualCameraDevice
        } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: cameraPosition) {
            // If a rear dual camera is not available, default to the rear dual wide camera.
            return dualWideCameraDevice
        }  else if let WideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) {
            // If the rear dual wide camera isn't available, default to the wide angle camera.
            return WideAngleCamera
        }
        return AVCaptureDevice.default(for: .video)
    }
    
    @objc func takePhoto() {
        let photoSettings = photoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageDatas = photo.fileDataRepresentation() {
            self.photoCaptured = UIImage(data: imageDatas)
            self.showPreview = true
        } else {
            
        }
    }
    
    func photoSettings() -> AVCapturePhotoSettings {
        let photoSettings: AVCapturePhotoSettings
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        photoSettings.flashMode = self.flashMode
        return photoSettings
    }
    
    func startRecording() {
        self.performFlash()
        let tempUrl = NSTemporaryDirectory() + "\(Date()).mov"
        movieOutput.startRecording(to: URL(fileURLWithPath: tempUrl), recordingDelegate: self)
        self.isRecording = true
    }
    
    func stopRecording() {
        movieOutput.stopRecording()
        self.resetProgressValues()
        self.isRecording = false
        self.undoFlash()
        self.showPreview = true
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            return
        }
        print("aç passe là ")
        DispatchQueue.main.async {
            convertVideoAndSaveTophotoLibrary(videoURL: outputFileURL)
            self.previewAsset = AVAsset(url: outputFileURL)
        }
    }
    
    func recordProgression() -> CGFloat {
        return recordDuration / maxDuration!
    }
    
    func makeProgression() {
        if let maxduration = self.maxDuration {
            if self.recordDuration <= maxduration && self.isRecording {
                self.recordDuration += 0.01
            }
            
            if self.recordDuration >= maxduration && self.isRecording {
                self.stopRecording()
                self.isRecording = false
                self.resetProgressValues()
            }
        }
    }
        
    func beginCapture() {
        
    }
    
    func resetProgressValues() {
        self.recordDuration = .zero
    }
    
    func dismissPreview() {
        showPreview = false
        previewAsset = nil
        photoCaptured = nil
    }
    
    func switchFlash() {
        switch flashMode {
        case .on:
            flashMode = .auto
        case .off:
            flashMode = .on
        case .auto:
            flashMode = .off
        @unknown default:
            return
        }
    }
    
    func performVideoFlash(device: AVCaptureDevice, mode: AVCaptureDevice.FlashMode) {
        guard device.hasTorch, device.isTorchAvailable else {
            print("Torch is not available")
            return
        }
        do {
            try device.lockForConfiguration()
            switch flashMode {
            case .on:
                device.torchMode = .on
            case .off:
                device.torchMode = .off
            case .auto:
                device.torchMode = .auto
            @unknown default:
                return
            }
            device.unlockForConfiguration()
        } catch {
            // write error no flash available
        }
    }
    
    func undoFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        } catch {
            // write error ?
        }
    }
    
    func performFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        performVideoFlash(device: device, mode: flashMode)
        
    }
    
    @ViewBuilder func progressBar(size: CGSize) -> some View {
        if let _ = self.maxDuration {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(backgroundProgressColor ?? Color.black.opacity(0.25))

                Rectangle()
                    .fill(progressColor ?? Color.white)
                    .frame(width: size.width * self.recordProgression())
            }
            .frame(height: progressbarHeight ?? 7)
            .frame(maxHeight: .infinity, alignment: .top)
        }

    }
}


//if let video = videoCompletionned {
//    Button {
//        convertVideoAndSaveTophotoLibrary(videoURL: testAssettoUrl(video))
//    } label: {
//        Image(systemName: "arrow.down.to.line")
//            .font(.system(size: 12))
//    }
//}

import UIKit
import AVFoundation
import AVKit
import Photos
// for test https://firebasestorage.googleapis.com/v0/b/miamapp-cc1ca.appspot.com/o/TEST%2Ftestvid.mp4?alt=media&token=90733c3b-03be-43dc-a600-25a417d306a1

func convertVideoAndSaveTophotoLibrary(videoURL: URL) {
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4").absoluteString
    _ = NSURL(fileURLWithPath: myDocumentPath)
    let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
    let filePath = documentsDirectory2.appendingPathComponent("video.mp4")
    deleteFile(filePath: filePath as NSURL)

    //Check if the file already exists then remove the previous file
    if FileManager.default.fileExists(atPath: myDocumentPath) {
        do { try FileManager.default.removeItem(atPath: myDocumentPath)
        } catch let error { print("erroring exit: \(error.localizedDescription)") }
    }

    // File to composit
    let asset = AVURLAsset(url: videoURL as URL)
    let composition = AVMutableComposition.init()
    composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)

    let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

    // Rotate to potrait
    let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
    let videoTransform:CGAffineTransform = clipVideoTrack.preferredTransform

    //fix orientation
    var videoAssetOrientation_  = UIImage.Orientation.up
    var isVideoAssetPortrait_  = false
    
    if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
        videoAssetOrientation_ = UIImage.Orientation.right
        isVideoAssetPortrait_ = true
    }
    if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
        videoAssetOrientation_ =  UIImage.Orientation.left
        isVideoAssetPortrait_ = true
    }
    if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
        videoAssetOrientation_ =  UIImage.Orientation.up
    }
    if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
        videoAssetOrientation_ = UIImage.Orientation.down;
    }
    
    transformer.setTransform(clipVideoTrack.preferredTransform, at: CMTime.zero)
    transformer.setOpacity(0.0, at: asset.duration)
    
    //adjust the render size if neccessary
    var naturalSize: CGSize
    if(isVideoAssetPortrait_){
        naturalSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
    } else {
        naturalSize = clipVideoTrack.naturalSize;
    }
    
    var renderWidth: CGFloat!
    var renderHeight: CGFloat!

    renderWidth = naturalSize.width
    renderHeight = naturalSize.height

    let parentlayer = CALayer()
    let videoLayer = CALayer()
    let watermarkLayer = CALayer()

    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
    videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
    videoComposition.renderScale = 1.0
    
    watermarkLayer.contents = UIImageView(image: UIImage(systemName: "square.grid.3x3.middle.filled")).asImage().cgImage
    
    parentlayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
    videoLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
    watermarkLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)

    parentlayer.addSublayer(videoLayer)
    parentlayer.addSublayer(watermarkLayer)

    // Add watermark to video
    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(60, preferredTimescale: 30))

    instruction.layerInstructions = [transformer]
    videoComposition.instructions = [instruction]

    let exporter = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetHighestQuality)
    exporter?.outputFileType = AVFileType.mov
    exporter?.outputURL = filePath
    exporter?.videoComposition = videoComposition

    exporter!.exportAsynchronously(completionHandler: {() -> Void in
        if exporter?.status == .completed {
            let outputURL: URL? = exporter?.outputURL
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
            }) { saved, error in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                    PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                        let newObj = avurlAsset as! AVURLAsset
                        print(newObj.url)
                        DispatchQueue.main.async(execute: {
                            print("new oBje: \(newObj.url.absoluteString)")
                        })
                    })
                    print ("resulted: \(fetchResult!)")
                }
            }
        }
    })
}

func deleteFile(filePath:NSURL) {
    guard FileManager.default.fileExists(atPath: filePath.path!) else {
        return
    }
    
    do { try FileManager.default.removeItem(atPath: filePath.path!)
    } catch { fatalError("Unable to delete file: \(error)") }
}

private extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImageFromMyView!
    }
    
 
    
    @objc func toImageView() -> UIImageView {
        let tempImageView = UIImageView()
        tempImageView.image = toImage()
        tempImageView.frame = frame
        tempImageView.contentMode = .scaleAspectFit
        return tempImageView
    }
    
   
}

