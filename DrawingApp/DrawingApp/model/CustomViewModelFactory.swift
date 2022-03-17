//
//  RandomValue.swift
//  DrawingApp
//
//  Created by 김동준 on 2022/02/28.
//

import Foundation
import os

class CustomViewModelFactory{
    private func makeUiniqueId() -> String{
        let allString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let uniqueStrings = (0 ..< 9).map{ _ in allString.randomElement() }
        var result: String = ""
        for (index, uniqueString) in uniqueStrings.enumerated(){
            if index % 3 == 0 && index != 0{
                result += "-"
            }
            guard let uniqueString = uniqueString?.description else {
                return ""
            }
            result += uniqueString.description
        }
        return result
    }
    
    private func makeRandomPoint() -> ViewPoint{
        return ViewPoint.randomPoint()
    }
    
    private func makeRandomRectangle() -> Rectangle{
        let size = ViewSize(width: 150, height: 120)
        return Rectangle(uniqueId: makeUiniqueId(), color: makeRandomColor(), point: makeRandomPoint(), size: size, alpha: 1.0)
    }
    
    private func makeRandomColor() -> ColorRGB{
        return ColorRGB.randomColor()
    }
    
    private func makeRandomPhoto(imageData: Data) -> Photo{
        let size = ViewSize(width: 150, height: 150)
        return Photo(imageData: imageData, uniqueId: makeUiniqueId(), point: makeRandomPoint(), size: size, alpha: 1.0)
    }
}

extension CustomViewModelFactory: CustomViewFactoryResponse{
    func randomRectangleViewModel() -> RectangleViewModelMutable {
        return makeRandomRectangle()
    }
    
    func randomPhotoViewModel(imageData: Data) -> PhotoViewModelMutable{
        return makeRandomPhoto(imageData: imageData)
    }
}
