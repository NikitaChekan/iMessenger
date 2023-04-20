//
//  UserError.swift
//  iMessenger
//
//  Created by jopootrivatel on 20.04.2023.
//

import Foundation

enum UserError {
    case NotFilled
    case photoNotExist
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .NotFilled:
            return NSLocalizedString("Заполните все поля!", comment: "")
        case .photoNotExist:
            return NSLocalizedString("Вы не выбрали фотографию!", comment: "")
        }
    }
}
