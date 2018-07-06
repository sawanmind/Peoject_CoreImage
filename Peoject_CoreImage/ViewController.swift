//
//  ViewController.swift
//  Peoject_CoreImage
//
//  Created by iOS Development on 6/25/18.
//  Copyright © 2018 Genisys. All rights reserved.
//

import UIKit
import CoreImage
import OpenGLES


class ViewController: UIViewController {
    
    var originalImage: UIImage?
    var context: CIContext?
    
    lazy var imageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = UIImage(named: "IMG_1071")
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        instance.addGestureRecognizer(tap)
        instance.isUserInteractionEnabled = true
        return instance
    }()
 
   
    fileprivate func switchToGPU() {
        let openGLContext = EAGLContext(api: .openGLES3)
        let _context = CIContext(eaglContext: openGLContext!)
        context = _context
    }
    
    override func viewDidLoad() {
        view.isUserInteractionEnabled = true
        view.addSubview(imageView)
        imageView.frame = view.frame
        originalImage = imageView.image
        switchToGPU()
    }
    
    var iterate = 0
    @objc func handleTap(sender:UITapGestureRecognizer){
       
//        if iterate == 0 {
//            imageView.image = self.originalImage
//            imageView.applyFilter(type: .sepia, context: context!)
//            iterate += 1
//        } else {
//            iterate = 0
//            imageView.image = self.originalImage
//            imageView.applyFilter(type: .bloom, context: context!)
//        }
    }
    
}


extension UIImageView {
    
    enum Filter {
        case sepia
        case bloom
    }
    
    
    fileprivate func getOutputImage(_ _filter: CIFilter?, _ context: CIContext) {
        if let output = _filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let exposureFilter = CIFilter(name: "CIExposureAdjust")
            exposureFilter?.setValue(output, forKey: kCIInputImageKey)
            exposureFilter?.setValue(1, forKey: kCIInputEVKey)
            
            if let exposureOutput = exposureFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let output = context.createCGImage(exposureOutput, from: exposureOutput.extent)
               DispatchQueue.main.async {
                    let result = UIImage(cgImage: output!)
                    self.image = result
                }
            }
        }
    }
    
    func applyFilter(type:Filter, context:CIContext){
        guard let cgimg = self.image?.cgImage else {return}
        DispatchQueue.global(qos: .userInitiated).async {
            
            let coreImage = CIImage(cgImage: cgimg)
            
            switch type {
            case .sepia:
                let filter = self.sepiaFilter(coreImage, intensity: 1)
                self.getOutputImage(filter, context)
            case .bloom:
                let filter = self.bloomFilter(coreImage, intensity: 1, radius: 10)
                self.getOutputImage(filter, context)
            }
        }
    }
    
  
    
    fileprivate func sepiaFilter(_ input:CIImage,intensity: Double)  -> CIFilter? {
        let sepiaFilter = CIFilter(name:"CISepiaTone")
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        return sepiaFilter
    }
    
    fileprivate func bloomFilter(_ input:CIImage, intensity: Double, radius: Double) -> CIFilter? {
        let bloomFilter = CIFilter(name:"CIBloom")
        bloomFilter?.setValue(input, forKey: kCIInputImageKey)
        bloomFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        bloomFilter?.setValue(radius, forKey: kCIInputRadiusKey)
        return bloomFilter
    }
}


































