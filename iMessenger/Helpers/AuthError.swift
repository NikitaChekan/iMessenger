//
//  AuthError.swift
//  iMessenger
//
//  Created by jopootrivatel on 19.04.2023.
//

import Foundation


enum AuthError {
    case NotFilled
    case invalidEmail
    case passwordNotMatched
    case unknownError
    case serverError
    case clientIdNotFound
    case tokenIdNotFound
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .NotFilled:
            return NSLocalizedString("Заполните все поля!", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Формат почты не является допустимым!", comment: "")
        case .passwordNotMatched:
            return NSLocalizedString("Пароли не совпадают!", comment: "")
        case .unknownError:
            return NSLocalizedString("Неизвестная ошибка!", comment: "")
        case .serverError:
            return NSLocalizedString("Ошибка сервера!", comment: "")
        case .clientIdNotFound:
            return NSLocalizedString("Ошибка получения client-id!", comment: "")
        case .tokenIdNotFound:
            return NSLocalizedString("Ошибка получения token-id!", comment: "")
        }
    }
}
