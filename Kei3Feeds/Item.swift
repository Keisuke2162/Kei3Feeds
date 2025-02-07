//
//  Item.swift
//  Kei3Feeds
//
//  Created by Kei on 2025/02/06.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
