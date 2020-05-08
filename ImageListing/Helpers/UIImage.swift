//
//  UIImage.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import UIKit

extension UIImage {

    enum FilterType : String {
        case chrome = "CIPhotoEffectChrome"
        case fade = "CIPhotoEffectFade"
        case instant = "CIPhotoEffectInstant"
        case mono = "CIPhotoEffectMono"
        case noir = "CIPhotoEffectNoir"
        case process = "CIPhotoEffectProcess"
        case tonal = "CIPhotoEffectTonal"
        case transfer =  "CIPhotoEffectTransfer"
    }
    
    func addFilter(filter : FilterType) -> UIImage? {
        let ciInput = CIImage(image: self)
        
        let filter = CIFilter(name: filter.rawValue)
        filter?.setValue(ciInput, forKey: "inputImage")
        
        guard let ciOutput = filter?.outputImage else {
            return nil
        }
        
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciOutput, from: ciOutput.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
