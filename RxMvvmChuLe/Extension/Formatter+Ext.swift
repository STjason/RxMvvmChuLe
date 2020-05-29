//
// Created by chieh hsun on 2020-05-29.
// Copyright (c) 2020 chieh hsun. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter
    }()
}

extension NumberFormatter {
    static let kiloComma: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
