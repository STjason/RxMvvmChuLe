//
//  APIs.swift
//  RxMvvmChuLe
//
//  Created by JX on 2020/7/15.
//  Copyright © 2020 chieh hsun. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Moya

class MaskApiManager {
    let provider = MoyaProvider<MaskAPI>()
    
    func fetchMask() -> PrimitiveSequence<SingleTrait, [DisplayMaskAnnotation]> {
        let tmpMask = provider.rx.request(.fetchMask)
            .filterSuccessfulStatusCodes()
            .map { result -> [TmpMaskAnnotation] in
                var masksAnnotation: [TmpMaskAnnotation] = []
                let decoder = MKGeoJSONDecoder()
                if let features = try? decoder.decode(result.data) as? [MKGeoJSONFeature] {
                    masksAnnotation = features.map { TmpMaskAnnotation(feature: $0) }
                }
                return masksAnnotation
            }
        let displayAnnotation = tmpMask.map { Dictionary(grouping: $0, by: { $0.finalCounty }) }
        .map { $0.map { key, value -> DisplayMaskAnnotation in
            let adtTitleCount = value.reduce(0, { $0 + $1.adtCount})
            var eachTxt = ""
            _ = value.map { eachTxt = eachTxt + $0.displayName + "：" + $0.adtDisplay + "個\n" }
            return DisplayMaskAnnotation(locateCoordinate: value[0].coordinate,
                                     key: key,
                                     adultCount: adtTitleCount,
                                     subTitleContent: eachTxt)
            }}
        
        return displayAnnotation
    }
}

