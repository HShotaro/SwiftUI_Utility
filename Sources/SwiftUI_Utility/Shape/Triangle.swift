//
//  File.swift
//  
//
//  Created by shotaro hirano on 2023/07/27.
//

import SwiftUI

/**
the triangle view
 
# Code Example
 ```
 Triangle()
     .frame(width: 50, height: 50)
     .foregroundColor(Color.red)
 ```
*/
public struct Triangle: Shape {
    public init () {
        
    }
    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
