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

class MaskMapViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func clickToRefresh(_ sender: Any) {
        fetchApi2()
    }
    let locationManager = CLLocationManager()
    
    var vm: MaskMapVMType!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm = MaskMapViewModel()
        
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        

        let tap = UITapGestureRecognizer(target: self, action: #selector(clickToHide))
        view.addGestureRecognizer(tap)
        
        vm.output.data
            .subscribe(onNext: { [weak self] data in
                print(">>>>> vm.output.data")
                print(data)
                DispatchQueue.main.async {
                    self?.mapView.addAnnotations(data)
                }
            }).disposed(by: disposeBag)
        
        fetchApi2()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchApi2()
    }
    
    private func fixCounty(_ params: inout [MaskAnnotation]) {
        for i in 0..<params.count {
            let store = params[i]
            var countyString = store.county
            
            if countyString.isEmpty {
                print(">>>>>")
                let startIdx = store.address.startIndex
                let endIdx = store.address.index(startIdx, offsetBy: 2)
                countyString = String(store.address[startIdx...endIdx])
                //params[i].county = countyString
            } else {
                print("-")
                print(countyString)
            }
        }
    }
    
    @objc func clickToHide() {
        super.view.window?.hideToast()
    }
    
    private func fetchApi2() {
        vm.input.fetchApi.onNext(())
        //fetchApi()
    }
    
    private func fetchApi() {
        guard let url = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json") else {
                  return
              }
              
              URLSession.shared.dataTask(with: url) { (data, response, error) in
                  guard let data = data else { return }
                  
                  let decoder = MKGeoJSONDecoder()
                  if let features = try? decoder.decode(data) as? [MKGeoJSONFeature] {

                      //fix county
                      var maskAnnotations = features.map {
                          MaskAnnotation(feature: $0)
                      }
                      
                      self.fixCounty(&maskAnnotations)
                      let r = Dictionary(grouping: maskAnnotations) { $0.county }

                      var displayAnnos: [DisplayAnno] = []

                      for (k, values) in r {
                          var allAdult: Int = 0
                          var subTitleContent = ""
                          for v in values {
                              if let ad = v.mask?.maskAdult, let txt = v.title {
                                  allAdult = allAdult + ad
                                  subTitleContent = subTitleContent + txt + "\(ad) \n"
                              }
                          }
                          
                          let da = DisplayAnno(coor: values[0].coordinate, key: k, adultCount: allAdult, subTitleContent: subTitleContent)
                          displayAnnos.append(da)
                      }
        
                      DispatchQueue.main.async {
                          //self.mapView.addAnnotations(maskAnnotations)
                          self.mapView.addAnnotations(displayAnnos)
                      }
                  }
              }.resume()
    }
}

extension MaskMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: false)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
         let annotation = view.annotation as? DisplayAnno
        
        if let txt = annotation?.toastTxt {
            super.view.window?.showToast(text: txt)
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as? DisplayAnno
        
        if let txt = annotation?.toastTxt {
            super.view.window?.showToast(text: txt)
        }

    }
}



//  MaskAnnotation.swift
import MapKit

extension DateFormatter {
    static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter
    }()
}

class DisplayAnno: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var county : String
    var title: String?
    var subtitle: String?
    var toastTxt: String?

    
    init(coor: CLLocationCoordinate2D, key: String, adultCount: Int, subTitleContent: String) {
        coordinate = coor
        county = key
        title = key + " : 成人總數量" + "\(adultCount)"
        //subtitle = "成人總數量" + "\(adultCount)"
        subtitle = ""
        toastTxt = subTitleContent
    }
}

class MaskAnnotation : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String? {
        mask?.name
    }
    var subtitle: String? {
        "成人:\(mask?.maskAdult ?? 0) 兒童:\(mask?.maskChild ?? 0)"
    }
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
            }
        }
    }
    
}

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
