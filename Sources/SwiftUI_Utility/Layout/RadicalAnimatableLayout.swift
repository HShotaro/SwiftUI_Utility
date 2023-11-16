//
//  SwiftUIView.swift
//  
//
//  Created by shotaro.hirano on 2023/11/16.
//

import SwiftUI

@available(iOS 16.0, *)
public struct RadicalAnimatableLayout: Layout {
    let offset: Angle
    
    public init(offset: Angle) {
        self.offset = offset
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let radius = min(bounds.size.width, bounds.size.height) / 3.0
            let angle = Angle.degrees(360.0 / Double(subviews.count)).radians
        
            for (index, subview) in subviews.enumerated() {
                var point = CGPoint(x: 0, y: -radius)
                    .applying(CGAffineTransform(
                        rotationAngle: angle * Double(index) + offset.radians))
                point.x += bounds.midX
                point.y += bounds.midY
                subview.place(at: point, anchor: .center, proposal: .unspecified)
            }
    }
}

@available(iOS 16.0, *)
extension SampleRadicalAnimatableView: Animatable {
    public var animatableData: Angle.AnimatableData {
        get { angle.animatableData }
        set { angle.animatableData = newValue }
    }
}

@available(iOS 16.0, *)
struct SampleRadicalAnimatableView: View {
    var angle: Angle
    
    public var body: some View {
        RadicalAnimatableLayout(offset: angle) {
            ForEach((1..<6)) { index in
                Text(index.description)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .foregroundColor(circleColor(index: index))
                            .frame(width: 30, height: 30)
                    )
            }
        }.frame(width: 250, height: 250)
    }
    
    private func circleColor(index: Int) -> Color {
        switch index % 5 {
        case 0:
            return .blue
        case 1:
            return .indigo
        case 2:
            return .mint
        case 3:
            return .cyan
        default:
            return .brown
        }
    }
}
@available(iOS 16.0, *)
public struct SampleRadicalAnimatableContentView: View {
    @State var angle: Angle
    
    public init(angle: Angle = .zero) {
        self.angle = angle
    }
    public var body: some View {
        SampleRadicalAnimatableView(angle: angle)
            .onTapGesture {
                withAnimation {
                    angle = Angle(degrees: Double.random(in: 0..<360))
                }
                
            }
    }
}

@available(iOS 16.0, *)
#Preview {
    SampleRadicalAnimatableContentView()
}
