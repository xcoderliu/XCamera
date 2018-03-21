//
//  ImageFilter.swift
//  XCamera
//
//  Created by 刘智民 on 11/03/2018.
//  Copyright © 2018 刘智民. All rights reserved.
//

import UIKit
typealias Filter = (CIImage) -> CIImage

func blur(radius: Double) -> Filter {
    return { image in
        let parameters: [String: Any] = [
            kCIInputRadiusKey: radius,
            kCIInputImageKey: image
        ]
        guard let filter = CIFilter(name: "CIGaussianBlur",
                                    withInputParameters: parameters)
            else { fatalError() }
        guard let outputImage = filter.outputImage
            else { fatalError() }
        return outputImage
    }
}

func generate(color: UIColor) -> Filter {
    return { _ in
        let parameters = [kCIInputColorKey: CIColor(cgColor: color.cgColor)]
        guard let filter = CIFilter(name: "CIConstantColorGenerator",
                                    withInputParameters: parameters)
            else { fatalError() }
        guard let outputImage = filter.outputImage
            else { fatalError() }
        return outputImage
    }
}

func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let parameters = [
            kCIInputBackgroundImageKey: image,
            kCIInputImageKey: overlay
        ]
        guard let filter = CIFilter(name: "CISourceOverCompositing",
                                    withInputParameters: parameters)
            else { fatalError() }
        guard let outputImage = filter.outputImage
            else { fatalError() }
        return outputImage.cropped(to: image.extent)
    }
}

func overlay(color: UIColor) -> Filter {
    return { image in
        let overlay = generate(color: color)(image).cropped(to: image.extent)
        return compositeSourceOver(overlay: overlay)(image)
    }
}

infix operator >>>
func >>>(filter1: @escaping Filter, filter2: @escaping Filter) -> Filter {
    return { image in filter2(filter1(image)) }
}
