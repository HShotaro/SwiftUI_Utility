//
//  File.swift
//  
//
//  Created by shotaro hirano on 2023/07/27.
//

import SwiftUI

/**
 A view that arranges its subviews in a vertical line.
 The width of the subiew is determined by the ratio to the width of the parent
 
# Code Example
 ```
 ZStack {
     LinearGradient(stops: gradientStops, startPoint: .init(x: 0.0, y: 0.5), endPoint: .init(x: 1.0, y: 0.5))
         .frame(height: 10)
         .cornerRadius(2)
     RelativeWidthVStack(relativeWidth: 0.7, alignment: .leading) {
         Color.currentGauge
             .frame(height: 10)
             .clipShape(RoundedCorners(topLeading: 2, bottomLeading: 2))
     }.frame(height: 10)
 }
 ```
*/
public struct RelativeWidthVStack<Content: View>: View {
    let relativeWidth: Double
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    let content: Content

    public init(relativeWidth: Double, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.relativeWidth = relativeWidth
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        if #available(iOS 16.0, *) {
            _RelativeWidthVStack(relativeWidth: relativeWidth, alignment: alignment, spacing: spacing) {
                content
            }
        } else {
            GeometryReader { proxy in
                VStack(alignment: alignment, spacing: spacing) {
                    content
                        .frame(width: proxy.frame(in: .local).width * relativeWidth)
                }
            }
        }
    }
}

@available(iOS 16.0, *)
fileprivate struct _RelativeWidthVStack: Layout {
    let relativeWidth: Double
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else {
            return
        }
        let anchor: UnitPoint
        let x: CGFloat
        switch alignment {
        case .leading:
            anchor = .leading
            x = bounds.minX
        case .trailing:
            anchor = .trailing
            x = bounds.maxX
        case .center:
            anchor = .center
            x = bounds.midX
        default:
            return
        }
        let height = height(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        var y = bounds.minY + height[0] / 2
        
        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: x, y: y),
                anchor: anchor,
                proposal: ProposedViewSize(width: (bounds.width) * max(0.0, min(1.0, relativeWidth)), height: subviews[index].sizeThatFits(proposal).height)
            )
            guard index < subviews.count - 1 else { return }
            let dHeight = (height[index] + height[index + 1]) / 2
            y += dHeight + spacing[index]
        }
    }
    
    private func height(subviews: Subviews) -> [CGFloat] {
        let subviewHeights = subviews.map { $0.sizeThatFits(.unspecified).height }
        return subviewHeights
    }

    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            if let spacing = spacing {
                return spacing
            }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .vertical)
        }
    }
}
