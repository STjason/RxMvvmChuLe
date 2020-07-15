//
//  ViewController.swift
//  RxMvvmChuLe
//
//  Created by chieh hsun on 2020/5/26.
//  Copyright © 2020 chieh hsun. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa
import Moya

class MaskMapViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!

    @IBAction func clickToRefresh(_ sender: Any) {
        fetchApi()
    }

    var vm: MaskMapVMType!
    let locationManager = CLLocationManager()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(clickToHide))
        view.addGestureRecognizer(tap)
        //let provider = MoyaProvider<MaskAPI>()
        //vm = MaskMapViewModel(provider: provider)
        vm = MaskMapViewModel()
        vm.output.displayMaskAnnotations
            .subscribe(onNext: { [weak self] data in
                DispatchQueue.main.async {
                    self?.mapView.addAnnotations(data)
                }
            }).disposed(by: disposeBag)

        fetchApi()
    }

    @objc func clickToHide() {
        super.view.window?.hideToast()
    }

    private func fetchApi() {
        vm.input.fetchApi.onNext(())
    }

}

extension MaskMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 700, longitudinalMeters: 700)
        mapView.setRegion(region, animated: true)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation as? DisplayMaskAnnotation

        if let txt = annotation?.toastTxt {
            super.view.window?.showToast(text: txt)
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as? DisplayMaskAnnotation

        if let txt = annotation?.toastTxt {
            super.view.window?.showToast(text: txt)
        }
    }
}
