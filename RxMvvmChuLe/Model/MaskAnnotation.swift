//
// Created by chieh hsun on 2020-05-29.
// Copyright (c) 2020 chieh hsun. All rights reserved.
//

import Foundation
import MapKit

class DisplayMaskAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var county: String
    var title: String?
    var subtitle: String?
    var toastTxt: String?

    init(locateCoordinate: CLLocationCoordinate2D, key: String, adultCount: Int, subTitleContent: String) {
        coordinate = locateCoordinate
        county = key

        let format = NumberFormatter()
        format.numberStyle = .decimal
        let adtKiloTxt = format.string(from: NSNumber(value: adultCount))
        
        title = key + "- 成人總數量 : " + (adtKiloTxt ?? "")
        subtitle = ""
        toastTxt = subTitleContent
    }
}

class TmpMaskAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String? {
        mask?.name
    }
    var subtitle: String?
    var mask: Mask?
    var county: String {
        mask?.county ?? ""
    }

    var address: String {
        mask?.address ?? ""
    }

    var adtCount: Int {
        mask?.maskAdult ?? 0
    }

    var displayName: String {
        title ?? ""
    }

    var finalCounty: String = ""
    var adtDisplay: String = ""

    init(feature: MKGeoJSONFeature) {
        coordinate = feature.geometry[0].coordinate
        if let data = feature.properties {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                let timeString = try decoder.singleValueContainer().decode(String.self)
                return DateFormatter.customFormatter.date(from: timeString) ?? Date()
            })

            mask = try? decoder.decode(Mask.self, from: data)
            if let mask = mask {
                if mask.county.isEmpty {
                    let startIdx = mask.address.startIndex
                    let endIdx = mask.address.index(startIdx, offsetBy: 2)
                    finalCounty = String(mask.address[startIdx...endIdx])
                } else {
                    finalCounty = mask.county
                }
                
                let format = NumberFormatter()
                format.numberStyle = .decimal
                let adtKiloTxt = format.string(from: NSNumber(value: mask.maskAdult))
                adtDisplay = adtKiloTxt ?? ""
            }
        }
    }

}
