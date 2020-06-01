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
import RxTest
import RxNimble
import Moya

@testable import RxMvvmChuLe

class RxMvvmChuLeTests: QuickSpec {

    override func spec() {
        describe("Request") {
            let initialClock = 0
            var vm: MaskMapVMType!
            var scheduler: TestScheduler!
            var disposeBag: DisposeBag!
            
            beforeEach {
                disposeBag = DisposeBag()
                scheduler = TestScheduler(initialClock: initialClock, simulateProcessingDelay: false)
            }

            context("StubMaskList") {
                it("Counts") {
                
                    let provider = MoyaProvider<MaskAPI>(stubClosure: { (service) -> StubBehavior in
                        return .immediate
                    })
                    vm = MaskMapViewModel(provider: provider)
                    
                    let result = ReplaySubject<Bool>.create(bufferSize: 1)
                    let maskAnnotations: Observable<[DisplayMaskAnnotation]> = vm.output.displayMaskAnnotations
                    
                    maskAnnotations
                    .map { $0.count == 3 }
                    .bind(to: result)
                    .disposed(by: disposeBag)
                
                    vm.input.fetchApi.onNext(())
   
                    expect(result).events(scheduler: scheduler, disposeBag: disposeBag)
                    .to(equal([ .next(0, true)]))
                }
                it("CountsName") {
                
                    let provider = MoyaProvider<MaskAPI>(stubClosure: { (service) -> StubBehavior in
                        return .immediate
                    })
                    vm = MaskMapViewModel(provider: provider)
                    
                    let result = ReplaySubject<[String]>.create(bufferSize: 1)
                    let maskAnnotations: Observable<[DisplayMaskAnnotation]> = vm.output.displayMaskAnnotations
                    
                    maskAnnotations
                    .map { $0.enumerated().map { $0.element.county } }
                    .bind(to: result)
                    .disposed(by: disposeBag)
                
                    vm.input.fetchApi.onNext(())
                
                    expect(result).events(scheduler: scheduler, disposeBag: disposeBag)
                    .toNot(contain([
                        .next(0, ["紐約市", "台北縣", "三重縣"]),
                    ]))
                }
            }
        }
    }
}
