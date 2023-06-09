//
//  ChatError.swift
//  iMessenger
//
//  Created by jopootrivatel on 10.06.2023.
//

import UIKit

// MARK: - Enumeration

enum ChatError {
    case cannotUnwrapToMChat
}

// MARK: - Extension

extension ChatError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .cannotUnwrapToMChat:
            return NSLocalizedString("Невозможно конвертировать в MChat", comment: "")
        }
    }
}
