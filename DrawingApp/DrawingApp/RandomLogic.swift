//
//  RandomValue.swift
//  DrawingApp
//
//  Created by 김동준 on 2022/02/28.
//

import Foundation

class RandomLogic{
    
    init(squareProtocol: SquareViewProtocol){
        self.squareProtocol = squareProtocol
    }
    private var squareProtocol: SquareViewProtocol?
    
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
    
    private func randomValue(property: RandomMax) -> Int{
        return property.randomValue
    }
    
    func makeSquareViewState(){
        let red = randomValue(property: .color)
        let blue = randomValue(property: .color)
        let green = randomValue(property: .color)
        let uniqueId = makeUiniqueId()
        let x = randomValue(property: .x)
        let y = randomValue(property: .y) + 44
        let alpha = randomValue(property: .alpha)
        let squareViewState = SquareViewState(red: red, green: green, blue: blue, uniqueId: uniqueId, x: x, y: y, width: 150, height: 120, alpha: alpha)
        squareProtocol?.makeSquareView(squareViewState: squareViewState)
    }
}


enum Color{
    case Red
    case Green
    case Blue
}

enum RandomMax: Int{
    case x = 670
    case y = 860
    case alpha = 10
    case color = 255
    
    var randomValue: Int{
        return Int.random(in: 1 ..< self.rawValue)
    }
}
