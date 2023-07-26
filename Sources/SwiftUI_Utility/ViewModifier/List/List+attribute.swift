//
//  File.swift
//  
//
//  Created by shotaro hirano on 2023/07/27.
//

import SwiftUI

public struct ListAttributeViewModifier<L: ListStyle>: ViewModifier {
    private let backgroundColor: Color
    private let listStyle: L
    public init(listStyle: L, backgroundColor: Color) {
        self.listStyle = listStyle
        self.backgroundColor = backgroundColor
    }

    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            baseContent(content: content)
                .scrollContentBackground(.hidden)
                        .background(backgroundColor)
        } else if #available(iOS 15.0, *), listStyle is PlainListStyle {
            baseContent(content: content)
                .background(backgroundColor)
        } else {
            baseContent(content: content)
                .onAppear {
                    UITableView.appearance().backgroundColor = UIColor(backgroundColor)
                }
                .onDisappear {
                    UITableView.appearance().backgroundColor = .systemGroupedBackground
                }
        }
    }

    private func baseContent(content: Content) -> some View {
        content
            .listStyle(listStyle)
    }
}

public extension View {
    func listAttribute(listStyle: some ListStyle, backgroundColor: Color) -> some View {
        modifier(ListAttributeViewModifier(listStyle: listStyle, backgroundColor: backgroundColor))
    }
}
