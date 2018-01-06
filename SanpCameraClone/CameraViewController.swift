//
//  CameraViewController.swift
//  SanpCameraClone
//
//  Created by Michael Budd on 1/5/18.
//  Copyright © 2018 Michael Budd. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Properties
    
    let captureSession =  AVCaptureSession()
    var capturePhotoOutput = AVCapturePhotoOutput()
    let previewView =  AVCaptureVideoPreviewLayer()
    var isCaptureSessionConfigured = false
    var photoSampleBuffer: CMSampleBuffer?
    var previewPhotoSampleBuffer: CMSampleBuffer?
    
    
    
    let sessionQueue = DispatchQueue(label: "session")
    
    // MARK: - Outlets
    @IBOutlet var cameraView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(previewView)
        previewView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewView.frame = view.layer.frame
        DispatchQueue.main.async {
            self.view.bringSubview(toFront: self.cameraView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if self.isCaptureSessionConfigured {
            if !self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        } else {
            self.sessionQueue.async {
                self.configureCaptureSession({ (success) in
                    guard success else { return }
                    
                    self.isCaptureSessionConfigured = true
                    
                    self.captureSession.startRunning()
                    
                    let videoPlayerConnection = self.previewView.connection
                    
                    DispatchQueue.main.async {
                        videoPlayerConnection?.videoOrientation = .portrait
                    }
                    
                })
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTapped(_ sender: UIButton) {
        print("button tapped")
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.flashMode = .auto
        photoSettings.isHighResolutionPhotoEnabled = true
        
        let capturePhotoOutput = self.capturePhotoOutput
        
        let videoPreviewLayerOrientation = previewView.connection?.videoOrientation
        
        self.sessionQueue.async {
            
            if let photoOutputConnection = capturePhotoOutput.connection(with: AVMediaType.video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            
        }
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
    func configureCaptureSession(_ completionHandler: ((_ success: Bool) -> Void)) {
        
        var success = false
        
        defer { completionHandler(success) } // Ensure all exit paths from func call completion
        
        // Get video input for default camera
        
        let videoCaptureDevice = defaultDevice()
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            
            print("Unable to obtain video input for default camera")
            
            return
        }
        
        // Photo Output
        
        let capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        
        // If live photo is supported then it is enabled
        capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
        
        // Ensure inputs and outputs can be added to session
        
        guard self.captureSession.canAddInput(videoInput) else { return }
        guard self.captureSession.canAddOutput(capturePhotoOutput) else { return }
        
        // Config session
        
        self.captureSession.beginConfiguration()
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        self.captureSession.addInput(videoInput)
        self.captureSession.addOutput(capturePhotoOutput)
        self.captureSession.commitConfiguration()
        
        self.capturePhotoOutput = capturePhotoOutput
        self.previewView.session = self.captureSession
        
        success = true
        
    }
    
    func defaultDevice() -> AVCaptureDevice {
        
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
            return device // Use dual camera on supported devices
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            return device
        } else {
            fatalError("All supported devices are expected to have at least one rear camera")
        }
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        self.photoSampleBuffer = photoSampleBuffer
        self.previewPhotoSampleBuffer = previewPhotoSampleBuffer
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
        guard error == nil else {
            print("Error in capture process: \(String(describing: error))")
            return
        }
        
        if let photoSampleBuffer = self.photoSampleBuffer {
            
        }
        
    }
    
    
    
    
    
}






