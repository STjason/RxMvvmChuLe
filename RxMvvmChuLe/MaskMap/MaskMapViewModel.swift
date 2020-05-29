//
//  MaskMapViewModel.swift
//  RxMvvmChuLe
//
//  Created by chieh hsun on 2020/5/26.
//  Copyright © 2020 chieh hsun. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Moya
import MapKit

protocol MaskMapVMInput {
    //input: trigger api
    var fetchApi: PublishSubject<Void> { get }
}

protocol MaskMapVMOutput {
    //output: UI display data
    var displayMaskAnnotations: Observable<[DisplayMaskAnnotation]> { get }
}

typealias MaskMapVMRelated = MaskMapVMInput & MaskMapVMOutput

protocol MaskMapVMType {
    var input: MaskMapVMInput { get }
    var output: MaskMapVMOutput { get }
}

extension MaskMapVMType where Self: MaskMapVMRelated {
    var input: MaskMapVMInput { self }
    var output: MaskMapVMOutput { self }
}

class MaskMapViewModel: MaskMapVMType, MaskMapVMRelated {
    
    var fetchApi: PublishSubject<Void> = PublishSubject()
    var displayMaskAnnotations: Observable<[DisplayMaskAnnotation]> = .empty()

    let disposeBag = DisposeBag()
    let provider = MoyaProvider<MaskAPI>()

    init() {
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

        displayMaskAnnotations = fetchApi.flatMap { displayAnnotation }
    }
}
