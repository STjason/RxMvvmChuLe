//
// Created by chieh hsun on 2020-05-29.
// Copyright (c) 2020 chieh hsun. All rights reserved.
//

import Foundation

struct Mask: Decodable {
    let name: String
    let phone: String
    let address: String
    let maskAdult: Int
    let maskChild: Int
    let updated: Date
    let available: String
    let note: String
    let customNote: String
    let website: String
    let county: String
    let town: String
    let cunli: String
    let servicePeriods: String
}
