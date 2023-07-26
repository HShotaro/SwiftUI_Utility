//
//  File.swift
//  
//
//  Created by shotaro hirano on 2023/07/27.
//

import SwiftUI

/**
 use to round the four corners of the View
 
# Code Example
 ```
 VStack {
     Image(systemName: "globe")
         .imageScale(.large)
         .foregroundColor(.accentColor)
     Text("Hello, world!")
 }
 .padding()
 .background(
     Color.cyan
 )
 .clipShape(RoundedCorners(topLeading: 10, topTrailing: 10))
 ```
*/
public struct RoundedCorners: Shape {
    public var topLeading: CGFloat = 0.0
    public var topTrailing: CGFloat = 0.0
    public var bottomLeading: CGFloat = 0.0
    public var bottomTrailing: CGFloat = 0.0
    
    public init(topLeading: CGFloat = 0, topTrailing: CGFloat = 0, bottomLeading: CGFloat = 0, bottomTrailing: CGFloat = 0) {
        self.topLeading = topLeading
        self.topTrailing = topTrailing
        self.bottomLeading = bottomLeading
        self.bottomTrailing = bottomTrailing
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        let topTrailing = min(min(self.topTrailing, h/2), w/2)
        let topLeading = min(min(self.topLeading, h/2), w/2)
        let bottomLeading = min(min(self.bottomLeading, h/2), w/2)
        let bottomTrailing = min(min(self.bottomTrailing, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - topTrailing, y: 0))
        path.addArc(center: CGPoint(x: w - topTrailing, y: topTrailing), radius: topTrailing,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - bottomTrailing))
        path.addArc(center: CGPoint(x: w - bottomTrailing, y: h - bottomTrailing), radius: bottomTrailing,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bottomLeading, y: h))
        path.addArc(center: CGPoint(x: bottomLeading, y: h - bottomLeading), radius: bottomLeading,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: topLeading))
        path.addArc(center: CGPoint(x: topLeading, y: topLeading), radius: topLeading,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        
        return path
    }
}
