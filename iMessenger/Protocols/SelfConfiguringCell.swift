//
//  SelfConfiguringCell.swift
//  iMessenger
//
//  Created by jopootrivatel on 13.04.2023.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure(with value: MChat)
}
