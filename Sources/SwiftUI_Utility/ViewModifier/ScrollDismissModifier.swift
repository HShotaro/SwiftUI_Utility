import SwiftUI

// MARK: - ScrollDismissModifier

/// ScrollView を下方向に引っ張って閉じる操作を共通化するモディファイア。
/// - iOS 18+: `onScrollGeometryChange` を使用（contentOffset.y < -threshold で発火）
/// - iOS 16/17: `GeometryReader` + `PreferenceKey` を使用
///   ScrollView コンテンツ最上部に `ScrollDismissSentinel()` を配置すること。
///
/// ## 使い方
/// ```swift
/// ScrollView {
///     ScrollDismissSentinel() // iOS 16/17 用。iOS 18+ では不要だが置いても副作用なし
///     content
/// }
/// .scrollDismiss {
///     isPresented = false
/// }
/// ```
public struct ScrollDismissModifier: ViewModifier {
    public let threshold: CGFloat
    public let onDismiss: () -> Void

    public func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content
                .onScrollGeometryChange(for: CGFloat.self) { geo in
                    geo.contentOffset.y
                } action: { _, offset in
                    guard offset < -threshold else { return }
                    onDismiss()
                }
        } else {
            content
                .coordinateSpace(name: "scrollDismiss")
                .onPreferenceChange(ScrollDismissOffsetKey.self) { offset in
                    guard offset > threshold else { return }
                    onDismiss()
                }
        }
    }
}

// MARK: - View Extension

extension View {
    /// ScrollView に適用して、下方向の引っ張りで action を実行する。
    /// iOS 16/17 では ScrollView コンテンツの最上部に `ScrollDismissSentinel()` を配置すること。
    public func scrollDismiss(threshold: CGFloat = 80, action: @escaping () -> Void) -> some View {
        modifier(ScrollDismissModifier(threshold: threshold, onDismiss: action))
    }
}

// MARK: - Sentinel View（iOS 16/17 用）

/// ScrollView コンテンツの最上部に配置して scroll offset を検知する 0pt ビュー。
/// iOS 18+ では `onScrollGeometryChange` が使われるため不要だが、配置しても副作用はない。
public struct ScrollDismissSentinel: View {
    public init() {}

    public var body: some View {
        Color.clear
            .frame(height: 0)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollDismissOffsetKey.self,
                        value: geo.frame(in: .named("scrollDismiss")).minY
                    )
                }
            )
    }
}

// MARK: - PreferenceKey（iOS 16/17 用）

public struct ScrollDismissOffsetKey: PreferenceKey {
    public static let defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
