//
//  EqualWidthHStack.swift
//  SwiftUI_Utility
//
//  Created by shotaro hirano on 2026/03/07.
//


/**
 A view that arranges its subviews in a horizontal line.
 Match the width of the subview to the maximum width of its subviews after automatic calculation
 
 # Code Example
  ```
 public struct SampleEqualWidthHStack: View {
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
             HStack {
                 EqualWidthHStack(spacing: 24) {
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
  ```
 
*/


import SwiftUI

public struct EqualWidthHStack<Content: View>: View {
    let spacing: CGFloat?
    let content: Content

    public init(spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        if #available(iOS 16.0, *) {
            _EqualWidthHStack(spacing: spacing) {
                content
            }
        } else {
            HStack(spacing: spacing) {
                content
            }
        }
    }
}

@available(iOS 16.0, *)
private struct _EqualWidthHStack: Layout {
    let spacing: CGFloat?

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        
        let maxWidth = maxWidth(subviews: subviews)
        let maxHeight = maxHeight(subviews: subviews)
        let spacings = spacing(subviews: subviews)
        let totalSpacing = spacings.reduce(0) { $0 + $1 }
        
        return CGSize(
            width: (maxWidth * CGFloat(subviews.count)) + totalSpacing,
            height: maxHeight
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        
        let maxWidth = maxWidth(subviews: subviews)
        let spacings = spacing(subviews: subviews)
        
        var x = bounds.minX + maxWidth / 2

        for index in subviews.indices {
            // すべてのサブビューに対して共通の幅 (maxWidth) を提案する
            let placementProposal = ProposedViewSize(width: maxWidth, height: bounds.height)
            
            subviews[index].place(
                at: CGPoint(x: x, y: bounds.midY),
                anchor: .center,
                proposal: placementProposal
            )
            
            if index < subviews.count - 1 {
                x += maxWidth + spacings[index]
            }
        }
    }

    private func maxWidth(subviews: Subviews) -> CGFloat {
        subviews.map { $0.sizeThatFits(.unspecified).width }.reduce(0) { max($0, $1) }
    }

    private func maxHeight(subviews: Subviews) -> CGFloat {
        subviews.map { $0.sizeThatFits(.unspecified).height }.reduce(0) { max($0, $1) }
    }

    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            if let spacing = spacing {
                return spacing
            }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal
            )
        }
    }
}

public struct SampleEqualWidthHStack: View {
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
            HStack {
                EqualWidthHStack(spacing: 24) {
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

@available(iOS 16.0, *)
#Preview {
    SampleEqualWidthHStack()
}
