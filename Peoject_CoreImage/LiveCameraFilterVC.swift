//
//  LiveCameraFilterVC.swift
//  Peoject_CoreImage
//
//  Created by iOS Development on 6/26/18.
//  Copyright © 2018 Genisys. All rights reserved.
//


import UIKit
import AVFoundation
import CoreImage
import OpenGLES

public class DynamicType<T> {
    public typealias Listener = (T) -> Void
    public var listener:Listener?
    public var value:T { didSet { listener?(value) } }
    public init(_ value:T) { self.value = value }
    public func bind(listner:Listener?) { self.listener = listner ; listener?(value) }
}



class LiveCameraFilterVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    var orientation: AVCaptureVideoOrientation = .portrait
    
  
    var _context : CIContext?
    var filterType: DynamicType<Filter?> = DynamicType(Filter.normal)
    
    var filterArray = [Filter]()
    
    enum Filter:String {
        case normal = ""
        case CIColorCrossPolynomial = "CIColorCrossPolynomial"
        case CIColorCube = "CIColorCube"
        case CIColorCubeWithColorSpace = "CIColorCubeWithColorSpace"
        case CIColorInvert = "CIColorInvert"
        case CIColorMap = "CIColorMap"
        case CIColorMonochrome = "CIColorMonochrome"
        case CIColorPosterize = "CIColorPosterize"
        case CIFalseColor = "CIFalseColor"
        case CIMaskToAlpha = "CIMaskToAlpha"
        case CIPhotoEffectChrome = "CIPhotoEffectChrome"
        case CIPhotoEffectFade = "CIPhotoEffectFade"
        case CIPhotoEffectInstant = "CIPhotoEffectInstant"
        case CIPhotoEffectMono = "CIPhotoEffectMono"
        case CIPhotoEffectNoir = "CIPhotoEffectNoir"
        case CIPhotoEffectProcess = "CIPhotoEffectProcess"
        case CIPhotoEffectTonal = "CIPhotoEffectTonal"
        case CIPhotoEffectTransfer = "CIPhotoEffectTransfer"
        case CISepiaTone = "CISepiaTone"
        case CIVignette = "CIVignette"
        case CIVignetteEffect = "CIVignetteEffect"

    }
    
    
    
    lazy var filteredImage: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        instance.addGestureRecognizer(tap)
        return instance
    }()
    
    lazy var label: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .center
        instance.textColor = UIColor.black
        instance.font = UIFont.systemFont(ofSize: 16, weight: .black)
        instance.translatesAutoresizingMaskIntoConstraints = false
        return instance
    }()
    
    func setupLabel(){
        filteredImage.addSubview(label)
        label.centerXAnchor.constraint(equalTo: filteredImage.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: filteredImage.bottomAnchor,constant: -100).isActive = true
        label.widthAnchor.constraint(equalTo: label.widthAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
    }
    var iterate = 0
    @objc func handleTap(sender:UITapGestureRecognizer){
        print(123)
       if iterate == 0 {
             filterType.value = Filter.CIColorCrossPolynomial
             iterate += 1
        } else if iterate == 1 {
            filterType.value = Filter.CIColorCube
            iterate += 1
       }else if iterate == 2 {
            filterType.value = Filter.CIColorCubeWithColorSpace
            iterate += 1
       } else if iterate == 3 {
            filterType.value = Filter.CIColorInvert
            iterate += 1
       } else if iterate == 4 {
            filterType.value = Filter.CIColorMap
            iterate += 1
       } else if iterate == 5 {
            filterType.value = Filter.CIColorMonochrome
            iterate += 1
       } else if iterate == 6 {
            filterType.value = Filter.CIColorPosterize
            iterate += 1
       } else if iterate == 7 {
            filterType.value = Filter.CIFalseColor
            iterate += 1
       } else if iterate == 8 {
            filterType.value = Filter.CIMaskToAlpha
            iterate += 1
       } else if iterate == 9 {
            filterType.value = Filter.CIPhotoEffectChrome
            iterate += 1
       } else if iterate == 10 {
            filterType.value = Filter.CIPhotoEffectFade
            iterate += 1
       } else if iterate == 11 {
            filterType.value = Filter.CIPhotoEffectInstant
            iterate += 1
       } else if iterate == 12 {
            filterType.value = Filter.CIPhotoEffectMono
            iterate += 1
       }else if iterate == 13 {
            filterType.value = Filter.CIPhotoEffectNoir
            iterate += 1
       }else if iterate == 14 {
            filterType.value = Filter.CIPhotoEffectProcess
            iterate += 1
       }else if iterate == 15 {
            filterType.value = Filter.CIPhotoEffectTonal
            iterate += 1
       }else if iterate == 16 {
            filterType.value = Filter.CISepiaTone
            iterate += 1
       } else if iterate == 17 {
            filterType.value = Filter.CIVignette
            iterate += 1
       } else {
            iterate = 0
            filterType.value = Filter.CIVignetteEffect
        }
      
    }
    
    
    fileprivate func switchToGPU() {
        let openGLContext = EAGLContext(api: .openGLES3)
        let context = CIContext(eaglContext: openGLContext!)
        _context = context
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.isUserInteractionEnabled = true
        view.addSubview(filteredImage)
        filteredImage.frame = view.frame
        setupLabel()
        switchToGPU()
        setupDevice()
        setupInputOutput()
    }
    
    override func viewDidLayoutSubviews() {
        orientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .authorized
        {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
                { (authorized) in
                    DispatchQueue.main.async
                        {
                            if authorized
                            {
                                self.setupInputOutput()
                            }
                    }
            })
        }
    }
    
    
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }
            else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        
        currentCamera = frontCamera
    }
    
    func setupInputOutput() {
        do {
            setupCorrectFramerate(currentCamera: currentCamera!)
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput)
            }
            let videoOutput = AVCaptureVideoDataOutput()
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    
    func setupCorrectFramerate(currentCamera: AVCaptureDevice) {
        for vFormat in currentCamera.formats {
            //see available types
            //print("\(vFormat) \n")
            
            var ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
            let frameRates = ranges[0]
            
            do {
                //set to 240fps - available types are: 30, 60, 120 and 240 and custom
                // lower framerates cause major stuttering
                if frameRates.maxFrameRate == 240 {
                    try currentCamera.lockForConfiguration()
                    currentCamera.activeFormat = vFormat as AVCaptureDevice.Format
                    //for custom framerate set min max activeVideoFrameDuration to whatever you like, e.g. 1 and 180.ac
                    currentCamera.activeVideoMinFrameDuration = frameRates.minFrameDuration
                    currentCamera.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
                }
                print(frameRates)
            }
            catch {
                print("Could not set active format")
                print(error)
            }
        }
    }
    
    fileprivate func setImagewithExposure(_ filter: CIFilter?) {
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let exposureFilter = CIFilter(name: "CIExposureAdjust")
            exposureFilter?.setValue(output, forKey: kCIInputImageKey)
            exposureFilter?.setValue(0, forKey: kCIInputEVKey)
            
            if let exposureOutput = exposureFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let output =  self._context?.createCGImage(exposureOutput, from: exposureOutput.extent)
                DispatchQueue.main.async {
                    let filteredImage = UIImage(cgImage: output!)
                    self.filteredImage.image = filteredImage
                }
                
            }
        }
    }
    
    fileprivate func resetImageToNormal(ciImage:CIImage) {
        
        if  let cgImage = self._context?.createCGImage(ciImage, from: ciImage.extent) {
            DispatchQueue.main.async {
                let filteredImage = UIImage(cgImage: cgImage)
                self.filteredImage.image = filteredImage
            }
        } else {
            print("Failed to reset image to normal")
        }
        
        
    }
    
    fileprivate func applyFilter(_ sampleBuffer:CMSampleBuffer, filter:String) -> CIFilter? {
        DispatchQueue.main.async {
            self.label.text = filter
        }
        
        let filter = CIFilter(name: filter)
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvImageBuffer: pixelBuffer!)
      
        filter?.setValue(cameraImage, forKey: kCIInputImageKey)
     
      
        
        return filter
    }
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
      
        connection.videoOrientation = orientation
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .background))
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.filterType.bind(listner: {
                
                if  $0?.rawValue == "" {
                    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
                    let cameraImage = CIImage(cvImageBuffer: pixelBuffer)
                    self.resetImageToNormal(ciImage: cameraImage)
                } else if let filter = $0?.rawValue {
                    if let filter = self.applyFilter(sampleBuffer, filter: filter) {
                        self.setImagewithExposure(filter)
                    }
                }
                
            })
           
        }
    }
}































