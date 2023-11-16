//
//  SwiftUIView.swift
//  
//
//  Created by shotaro.hirano on 2023/11/16.
//

import SwiftUI

/**
 The circular layout introduced in this video (https://developer.apple.com/videos/play/wwdc2022/10056/).
 The element ranked first is positioned at the topmost position.
 
# Code Example
 ```
 RadicalLayout {
     ForEach((1..<6)) { index in
         Text(index.description)
             .foregroundColor(.white)
             .background(
                 Circle()
                     .foregroundColor(circleColor(index: index))
                     .frame(width: 30, height: 30)
             )
             .radicalLayoutRank((index + 2) % 5 + 1)
     }
 }.frame(width: 250, height: 250)
 ```
*/

@available(iOS 16.0, *)
public struct RadicalLayout: Layout {
    public init() {
        
    }
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let radius = min(bounds.size.width, bounds.size.height) / 3.0
            let angle = Angle.degrees(360.0 / Double(subviews.count)).radians
            let ranks = subviews.map { subview in
                subview[RadicalLayoutRank.self]
            }
        
            for (index, subview) in subviews.enumerated() {
                var point = CGPoint(x: 0, y: -radius)
                    .applying(CGAffineTransform(
                        rotationAngle: angle * Double(index) + getOffset(ranks, angle: angle)))
                point.x += bounds.midX
                point.y += bounds.midY
                subview.place(at: point, anchor: .center, proposal: .unspecified)
            }
    }
    
    private func getOffset(_ ranks: [Int], angle: Double) -> Double {
        let no1Index = ranks.firstIndex(of: 1) ?? 0
        return Angle.degrees(360.0).radians - angle * Double(no1Index)
    }
}

private struct RadicalLayoutRank: LayoutValueKey {
    static let defaultValue: Int = 1
}

extension View {
    @available(iOS 16.0, *)
    public func radicalLayoutRank(_ value: Int) -> some View {
        layoutValue(key: RadicalLayoutRank.self, value: value)
    }
}
