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
    case cannotGetUserInfo
    case cannotUnwrapToUser
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .NotFilled:
            return NSLocalizedString("Заполните все поля!", comment: "")
        case .photoNotExist:
            return NSLocalizedString("Вы не выбрали фотографию!", comment: "")
        case .cannotGetUserInfo:
            return NSLocalizedString("Невозможно загрузить информацию о User из Firebase!", comment: "")
        case .cannotUnwrapToUser:
            return NSLocalizedString("Невозможно конвертировать MUser из User!", comment: "")
        }
    }
}
