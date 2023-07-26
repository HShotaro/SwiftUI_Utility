//
//  File.swift
//  
//
//  Created by shotaro hirano on 2023/07/27.
//

import SwiftUI

public struct ConfirmationDialogViewModifier: ViewModifier {
    private let isPresented: Binding<Bool>
    private let title: String?
    private let message: String?
    private let actions: [ConfirmationDialogAction]
    public init(
        isPresented: Binding<Bool>,
        title: String?,
        message: String?,
        actions: [ConfirmationDialogAction]
    ) {
        self.isPresented = isPresented
        self.title = title
        self.message = message
        self.actions = actions
    }

    public func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .confirmationDialog(
                    title ?? "",
                    isPresented: isPresented
                ) {
                    ForEach(actions) { action in
                        Button(action.title, role: action.role) {
                            action.tapHandler?()
                        }
                    }
                } message: {
                    Text(message ?? "")
                }

        } else {
            content
                .actionSheet(isPresented: isPresented) {
                    ActionSheet(
                        title:
                            Text(title ?? ""),
                        message:
                            message != nil ? Text(message ?? "") : nil,
                        buttons:
                            actions.map { action in
                                switch action.type {
                                case .default:
                                    return SwiftUI.Alert.Button.default(
                                        Text(action.title),
                                        action: action.tapHandler
                                    )
                                case .cancel:
                                    return SwiftUI.Alert.Button.cancel(
                                        Text(action.title),
                                        action: action.tapHandler
                                    )
                                case .destructive:
                                    return SwiftUI.Alert.Button.destructive(
                                        Text(action.title),
                                        action: action.tapHandler
                                    )
                                }
                            }
                    )
                }
        }
    }
}

public extension View {
    func confirmationDialog(
        isPresented: Binding<Bool>,
        title: String?,
        message: String? = nil,
        actions: [ConfirmationDialogAction]
    ) -> some View {
        modifier(ConfirmationDialogViewModifier(isPresented: isPresented, title: title, message: message, actions: actions))
    }
}

public struct ConfirmationDialogAction: Identifiable {
    public init(
        title: String,
        type: ActionType,
        tapHandler: (() -> Void)?
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.type = type
        self.tapHandler = tapHandler
    }
    public let id: String

    public enum ActionType {
        case `default`
        case cancel
        case destructive
    }
    let title: String
    let type: ActionType
    let tapHandler: (() -> Void)?

    @available(iOS 15.0, *)
    public var role: ButtonRole? {
        switch type {
        case .default:
            return nil
        case .cancel:
            return ButtonRole.cancel
        case .destructive:
            return ButtonRole.destructive
        }
    }
}
