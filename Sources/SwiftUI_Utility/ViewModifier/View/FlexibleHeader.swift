//
//  FlexibleHeader.swift
//  SwiftUI_Utility
//
//  Created by shotaro hirano on 2026/04/04.
//

import SwiftUI

/// スクロールオフセットを保持する Observable オブジェクト。
/// `FlexibleHeaderScrollViewModifier` が書き込み、`FlexibleHeaderContentModifier` が読み取る。
@available(iOS 17.0, *)
@Observable private class FlexibleHeaderGeometry {
    var offset: CGFloat = 0
}

/// スクロールオフセットに応じてヘッダービューのフレームを拡大・オフセット補正するビューモディファイア。
///
/// - Note: `flexibleHeaderScrollView()` を適用した `ScrollView` の子ビューにのみ使用できる。
@available(iOS 17.0, *)
private struct FlexibleHeaderContentModifier: ViewModifier {
    @Environment(FlexibleHeaderGeometry.self) private var geometry
    let height: CGFloat

    func body(content: Content) -> some View {
        let h = height - geometry.offset
        content
            .frame(height: h)
            .padding(.bottom, geometry.offset)
            .offset(y: geometry.offset)
    }
}

/// `onScrollGeometryChange` でスクロール位置を監視し、``FlexibleHeaderContentModifier`` に伝達するビューモディファイア。
///
/// - Note: SwiftUI の `ScrollGeometry.contentOffset.y` は最上部で 0、引き下げ時に負の値になる。
///   UIKit とは異なり `contentInsets.top` を加算する必要はない。
@available(iOS 18.0, *)
private struct FlexibleHeaderScrollViewModifier: ViewModifier {
    @State private var geometry = FlexibleHeaderGeometry()

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                min(geometry.contentOffset.y, 0)
            } action: { _, offset in
                geometry.offset = offset
            }
            .environment(geometry)
    }
}

// MARK: - View Extensions

@available(iOS 18.0, *)
public extension ScrollView {
    /// スクロール位置を監視してフレキシブルヘッダーのズーム効果を有効にする。
    ///
    /// `ScrollView` に適用することで、内部の ``View/flexibleHeaderContent(height:)`` が
    /// スクロールオフセットを受け取れるようになる。
    ///
    /// ## 使い方
    /// ```swift
    /// ScrollView {
    ///     HeaderView()
    ///         .flexibleHeaderContent(height: 250)
    ///     content
    /// }
    /// .flexibleHeaderScrollView()
    /// ```
    @MainActor func flexibleHeaderScrollView() -> some View {
        modifier(FlexibleHeaderScrollViewModifier())
    }
}

@available(iOS 17.0, *)
public extension View {
    /// 引き下げ時にビューを引き伸ばすフレキシブルヘッダー効果を適用する。
    ///
    /// `flexibleHeaderScrollView()` を適用した `ScrollView` の直下に配置したヘッダービューに使用する。
    /// 最上部を超えて引き下げると `height` を超えてフレームが拡大し、ズーム効果が得られる。
    ///
    /// ヘッダービュー内部で子ビューのサイズを動的に決定するには `GeometryReader` を併用すること。
    /// `GeometryReader` がこのモディファイアの変化した提案高さを受け取り、
    /// 子ビューのフレームをズームに追随させることができる。
    ///
    /// - Important: `backgroundExtensionEffect()` などの視覚エフェクトは、
    ///   ヘッダービューの **内部**（`.clipped()` の直後）に適用すること。
    ///   外側に適用するとフレーム変更が視覚レイヤーに反映されず、ズーム効果が無効になる。
    /// - Parameter height: 通常時のヘッダー高さ（ポイント）。
    func flexibleHeaderContent(height: CGFloat) -> some View {
        modifier(FlexibleHeaderContentModifier(height: height))
    }
}

/// グラジェントとシステムシンボルを重ねた装飾用背景ビュー。
/// ``SampleFlexibleHeaderView`` のヘッダーコンテンツとして使用する。
///
/// `GeometryReader` で現在のフレーム高さを読み取り、SF Symbol のサイズを明示指定することで
/// `flexibleHeaderContent(height:)` によるフレーム変更にズームを追随させる。
/// `scaledToFit` のみでは ZStack 内でサイズが追随しないため、この方式を採用している。
@available(iOS 26.0, *)
private struct SymbolBackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [.teal, .indigo],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                Image(systemName: "network")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(.white.opacity(0.2))
                    .accessibilityHidden(true)
                Image(systemName: "paintpalette.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: max(geo.size.height - 120, 0))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    .offset(y: 80)

            }
        }
        .clipped()
        .backgroundExtensionEffect()
    }
}

/// 上部を引き下げると ``SymbolBackgroundView`` がズームするフレキシブルヘッダー付きスクロールビューのサンプル。
///
/// ズーム効果は以下の 3 コンポーネントの連携で実現する:
/// 1. `ScrollView` に `flexibleHeaderScrollView()` を適用してスクロールオフセットを監視
/// 2. ヘッダービューに `flexibleHeaderContent(height:)` を適用してフレームをオフセット量に応じて拡大
/// 3. ヘッダービュー内部の `GeometryReader` で拡大後の高さを読み取り、子ビューをズームに追随させる
///
/// ## 使い方
/// ```swift
/// NavigationStack {
///     SampleFlexibleHeaderView(height: 250)
/// }
/// ```
@available(iOS 26.0, *)
public struct SampleFlexibleHeaderView: View {
    private let height: CGFloat

    /// - Parameter height: 通常時のヘッダー高さ（ポイント）。
    public init(height: CGFloat) {
        self.height = height
    }

    public var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 14.0) {

                SymbolBackgroundView()
                    .flexibleHeaderContent(height: height)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Landmark Name")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Landmark Description")
                        .textSelection(.enabled)

                    ForEach(0..<20, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 60)
                    }
                }
                .padding(.horizontal, 26)
            }
        }
        .flexibleHeaderScrollView()
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        NavigationStack {
            SampleFlexibleHeaderView(height: 250)
        }
    } else {
        Text("iOS 18 Required")
    }
}
