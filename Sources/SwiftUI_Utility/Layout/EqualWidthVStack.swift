//
//  File.swift
//  
//
//  Created by shotaro hirano on 2023/07/27.
//

import SwiftUI

/**
 A view that arranges its subviews in a vertical line.
 Match the width of the subview to the maximum width of its subviews after automatic calculation
 
# Code Example
 ```
 HStack {
     ForEach(tabs) { tab in
         Button {
             if let index = tabs.firstIndex(of: tab) {
                 withAnimation(.easeOut) {
                     selectedIndex = index
                 }
             }
         } label: {
             EqualWidthVStack(spacing: 4) {
                 Text(tab.name)
                     .font(tabs[selectedIndex] == tab ? tab.nameSelectedFont: tab.nameFont)
                     .foregroundColor(tab.nameTextColor)
                 if tabs[selectedIndex] == tab {
                     indicatorView().matchedGeometryEffect(id: "selected_indicator_id", in: namespace)
                 } else {
                     Color.clear
                         .frame(width: 20, height: 4)
                 }
             }
         }
     }
     Spacer()
 }
 ```
*/
public struct EqualWidthVStack<Content: View>: View {
    let spacing: CGFloat?
    let content: Content

    public init(spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        if #available(iOS 16.0, *) {
            _EqualWidthVStack(spacing: spacing) {
                content
            }
        } else {
            VStack(spacing: spacing) {
                content
            }
        }
    }
}

@available(iOS 16.0, *)
private struct _EqualWidthVStack: Layout {
    let spacing: CGFloat?
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = maxWidth(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }
        let totalHeight = height(subviews: subviews).reduce(0) { $0 + $1 }
        return CGSize(
                width: maxWidth,
                height: totalHeight + totalSpacing
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        let maxWidth = maxWidth(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let height = height(subviews: subviews)

        var y = bounds.minY + height[0] / 2

        for index in subviews.indices {
            let placementProposal = ProposedViewSize(width: maxWidth, height: height[index])
            subviews[index].place(
                at: CGPoint(x: bounds.midX, y: y),
                anchor: .center,
                proposal: placementProposal)
            guard index < subviews.count - 1 else { return }
            let dHeight = (height[index] + height[index + 1]) / 2
            y += dHeight + spacing[index]
        }
    }

    private func maxWidth(subviews: Subviews) -> CGFloat {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxWidth: CGFloat = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            max(currentMax, subviewSize.width)
        }

        return maxWidth
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

public struct SampleEqualWidthVStack: View {
    enum Tab: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        case home = "ホーム"
        case search = "検索"
        case library = "ライブラリ"

        var color: Color {
            switch self {
            case .home: return .blue
            case .search: return .orange
            case .library: return .purple
            }
        }
    }
    
    public init() {
        
    }
    
    @Namespace private var namespace
    @State var selectedTab: Tab = .home
    
    public var body: some View {
        VStack(spacing: 0) {
            // カスタム上タブ
            HStack(spacing: 24) {
                ForEach(Tab.allCases) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    } label: {
                        EqualWidthVStack(spacing: 6) {
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(selectedTab == tab ? .primary : .secondary)
                                .padding(.horizontal, 4)
                            
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.green)
                                    .frame(width: 24, height: 4)
                                    .matchedGeometryEffect(id: "selected_indicator", in: namespace)
                            } else {
                                Color.clear
                                    .frame(width: 24, height: 4)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            Divider()

            // ページコンテンツ (TabView)
            TabView(selection: $selectedTab) {
                ForEach(Tab.allCases) { tab in
                    pageContent(for: tab)
                        .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // スワイプ可能なページスタイル
        }
    }
    
    @ViewBuilder
    private func pageContent(for tab: Tab) -> some View {
        ZStack {
            tab.color.opacity(0.1).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: systemIcon(for: tab))
                    .font(.system(size: 60))
                    .foregroundColor(tab.color)

                Text("\(tab.rawValue) ページ")
                    .font(.title2)
                    .fontWeight(.medium)

                Text("左右にスワイプしてページを切り替えられます。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    private func systemIcon(for tab: Tab) -> String {
        switch tab {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical.fill"
        }
    }
}
