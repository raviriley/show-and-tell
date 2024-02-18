//
//  CameraFeedManager.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/17/24.
//

import AVFoundation
import UIKit

class CameraFeedManager: NSObject, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession?
    private let photoOutput = AVCapturePhotoOutput()
    private var captureCompletionHandler: ((UIImage?) -> Void)?

    override init() {
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        // Ensure access is granted
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break // Proceed
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else { return }
                self.setupCaptureSession()
            }
            return
        default:
            print("Camera access denied")
            return
        }

        captureSession = AVCaptureSession()
        guard let captureSession = captureSession, let videoDevice = AVCaptureDevice.default(for: .video),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput) else {
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo // Use high quality for single photo capture
        captureSession.addInput(videoDeviceInput)
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            captureSession.commitConfiguration()
            captureSession.startRunning()
        }
    }
    
    func captureImage(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        self.captureCompletionHandler = completion
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            captureCompletionHandler?(nil)
            return
        }
        captureCompletionHandler?(image)
    }
}
