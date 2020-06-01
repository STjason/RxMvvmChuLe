//
//  RxMvvmChuLeTests.swift
//  RxMvvmChuLeTests
//
//  Created by chieh hsun on 2020/5/26.
//  Copyright © 2020 chieh hsun. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxNimble
import Moya

@testable import RxMvvmChuLe

class RxMvvmChuLeTests: QuickSpec {

    let provider = MoyaProvider<MaskAPI>(stubClosure: { (service) -> StubBehavior in
        return .immediate
    })
    var vm: MaskMapVMType!
    let disposeBag = DisposeBag()

    override func spec() {
        

        describe("Request") { [weak self] in
            guard let `self` = self else {
                return
            }

            beforeEach {
                self.vm = MaskMapViewModel(provider: self.provider)
                self.vm.input.fetchApi.onNext(())
            }

            context("CountiesAdultMask") {
                it("Counts") {
                    var result: Observable<Bool> = self.setSource(false)
                    let maskAnnotations: Observable<[DisplayMaskAnnotation]> = self.vm.output.displayMaskAnnotations
                    result = maskAnnotations.map { $0.count == 3 }
                
                    expect(result).last.to(beTrue())
                }
            }
        }
    }

    func setSource<Value>(_ value: Value) -> Observable<Value> {
        return .create { observer in
            observer.onNext(value)
            return Disposables.create()
        }
    }
}
