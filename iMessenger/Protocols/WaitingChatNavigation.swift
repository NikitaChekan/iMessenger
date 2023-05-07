//
//  WaitingChatNavigation.swift
//  iMessenger
//
//  Created by jopootrivatel on 07.05.2023.
//

import Foundation

protocol WaitingChatNavigation: AnyObject {
    func removeWaitingChat(chat: MChat)
    func chatToActive(chat: MChat)
}
