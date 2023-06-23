//
//  ImageItem.swift
//  iMessenger
//
//  Created by jopootrivatel on 22.06.2023.
//

import UIKit
import MessageKit

struct ImageItem: MediaItem {
    
    // MARK: - Properties
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
