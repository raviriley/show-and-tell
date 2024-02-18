//
//  CameraFeedManager.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/17/24.
//

import AVFoundation
import UIKit

class CameraFeedManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession?
    private let photoOutput = AVCapturePhotoOutput()
    private var captureCompletionHandler: ((UIImage?, Error?) -> Void)?
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    @Published var isSessionReady = false
    @Published var sessionError: Error?
    
    override init() {
        super.init()
        checkCameraAuthorizationStatus()
    }
    
    private func checkCameraAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sessionQueue.async { [weak self] in self?.setupCaptureSession() }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    DispatchQueue.main.async {
                        self?.sessionError = NSError(domain: "CameraFeedManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Camera access was not granted"])
                    }
                    return
                }
                self?.sessionQueue.async { self?.setupCaptureSession() }
            }
        default:
            DispatchQueue.main.async {
                self.sessionError = NSError(domain: "CameraFeedManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Camera access denied"])
            }
        }
    }
    
    private func setupCaptureSession() {
        let session = AVCaptureSession()
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else {
            DispatchQueue.main.async {
                self.sessionError = NSError(domain: "CameraFeedManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to create video device input"])
            }
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        session.addInput(videoDeviceInput)
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            session.commitConfiguration()
            self.captureSession = session
            
            // Start the session on the sessionQueue to avoid blocking the main thread
            sessionQueue.async {
                session.startRunning()
                // After starting the session, check if it's running to update isSessionReady
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Short delay to ensure session is running
                    if session.isRunning {
                        self.isSessionReady = true
                    } else {
                        self.sessionError = NSError(domain: "CameraFeedManager", code: -6, userInfo: [NSLocalizedDescriptionKey: "Failed to start capture session"])
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.sessionError = NSError(domain: "CameraFeedManager", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to add photo output"])
            }
        }
    }

    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard isSessionReady else {
            completion(nil, sessionError)
            return
        }
        
        captureCompletionHandler = completion
        
        sessionQueue.async {
            let settings = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    // Delegate method implementation remains unchanged
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.captureCompletionHandler?(nil, error)
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                self.captureCompletionHandler?(nil, NSError(domain: "CameraFeedManager", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to process image data"]))
                return
            }
            
            self.captureCompletionHandler?(image, nil)
        }
    }
}

