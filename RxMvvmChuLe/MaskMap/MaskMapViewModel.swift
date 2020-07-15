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


    //init(provider: MoyaProvider<MaskAPI>) {
    init(manager: MaskApiManager = MaskApiManager()) {
        displayMaskAnnotations = fetchApi.flatMap { manager.fetchMask() }
    }
}
