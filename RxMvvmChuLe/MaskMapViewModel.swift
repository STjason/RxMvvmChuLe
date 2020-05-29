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
    // fetch api
    var fetchApi: PublishSubject<Void> { get }
}

protocol MaskMapVMOutput {
    // api result
    var data: Observable<[DisplayAnno]> { get }
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
    var data: Observable<[DisplayAnno]> = .empty()
    var data2: Observable<Void> = .empty()
    
    let disposeBag = DisposeBag()
    let provider = MoyaProvider<MaskAPI>()
    
    init() {
        
        let masksAnno = provider.rx.request(.fetchMask)//.debug(">> request")
            .filterSuccessfulStatusCodes() // todo: how to json snakeCase
            .map { result -> [MaskAnnotation] in
                var masksAnno: [MaskAnnotation] = []
                let decoder = MKGeoJSONDecoder()
                if let features = try? decoder.decode(result.data) as? [MKGeoJSONFeature] {
                    masksAnno = features.map { MaskAnnotation(feature: $0) }
                }
                return masksAnno
            }
        
        let displayAnno = masksAnno.map { Dictionary(grouping: $0, by: { $0.finalCounty }) }
            .map { $0.map { key, value -> DisplayAnno in
                let adtTitleCount = value.reduce(0, { $0 + $1.adtCount})
                var eachTxt = ""
                _ = value.map { eachTxt = eachTxt + $0.displayName + "\($0.adtCount)" + "\n" }
                return DisplayAnno(coor: value[0].coordinate, key: key, adultCount: adtTitleCount, subTitleContent: eachTxt)
                }}

        data = fetchApi.flatMap { displayAnno }
    }
}

/// moya
public enum MaskAPI {
    case fetchMask
}

extension MaskAPI: TargetType {
    
    public var baseURL: URL {
        URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/")!
    }
    
    public var path: String {
        switch self {
        case .fetchMask:
            return "json/points.json"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .fetchMask:
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        case .fetchMask:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        nil
    }
    
    public var sampleData: Data {
        "".data(using: String.Encoding.utf8)!
    }
    
}
