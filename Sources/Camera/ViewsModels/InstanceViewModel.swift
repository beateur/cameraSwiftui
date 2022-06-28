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
    
    // MARK: PHOTO PROCESSING PROPERTIES
    @Published var photoCaptured: UIImage?
    
    // MARK: PROGRESS BAR
    @Published var recordDuration: CGFloat = 0
    var progressColor: Color? = nil
    var backgroundProgressColor: Color? = nil
    var progressbarHeight: CGFloat? = nil
    var maxDuration: CGFloat? = nil
    
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
    
    func removeSessionInputs() {
        for input in session.inputs {
            session.removeInput(input)
        }
    }
    
    func switchPosition() {
        switch cameraPosition {
        case .unspecified, .front:
            print("unspecified front")
            cameraPosition = .back
        case .back:
            print("back")
            cameraPosition = .front
        @unknown default:
            print("default")
            cameraPosition = .back
        }
    }
    
    func switchCamera() {
        if session.inputs.isEmpty {
           return
        }
        
        removeSessionInputs()
        
        switchPosition()
        
        if let newCam = createDevice() {
            do {
                let newInput = try AVCaptureDeviceInput(device: newCam)
                cameraInput = newInput
                
                let audiodevice = AVCaptureDevice.default(for: .audio)
                let audioinput = try AVCaptureDeviceInput(device: audiodevice!)
                                        
                if self.session.canAddInput(cameraInput) && self.session.canAddInput(audioinput) {

                    self.session.addInput(cameraInput)
                    self.session.addInput(audioinput)
                    adjustVideoMirror()
                }
            } catch {
                print("catched no avcapture device create for \(newCam)")
                // handle plus tard
            }
        }
    }
    
    func setup() {
        do {
            self.session.beginConfiguration()

            if let cameradevice = createDevice() {
                if cameraInput == nil {
                    cameraInput = try AVCaptureDeviceInput(device: cameradevice)
                }

                let audiodevice = AVCaptureDevice.default(for: .audio)
                let audioinput = try AVCaptureDeviceInput(device: audiodevice!)
                                        
                if self.session.canAddInput(cameraInput) && self.session.canAddInput(audioinput) {
                    self.session.addInput(cameraInput)
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

        DispatchQueue.main.async {
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
