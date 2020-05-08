//
//  FadeFilter.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 08/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import UIKit

struct FadeFilter {
    
    private var filter: CIFilter
    private let ciContext = CIContext()
    
    init?() {
        guard let filter = CIFilter(name: "CIPhotoEffectFade") else {
            return nil
        }
        self.filter = filter
    }
    
    func filter(image: UIImage) -> UIImage? {
        let ciInput = CIImage(image: image)
        
        filter.setValue(ciInput, forKey: "inputImage")
        
        guard let ciOutput = filter.outputImage else {
            return nil
        }
        
        guard let cgImage = ciContext.createCGImage(ciOutput, from: ciOutput.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
        
    }
    
    
}
