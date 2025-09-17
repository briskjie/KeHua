//
//  Item.swift
//  KeHua
//
//  Created by chenxiangxu on 2025/9/17.
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
