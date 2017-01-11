//
//  ViewController.swift
//  GMaps
//
//  Created by Neil Weintraut on 1/11/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class ViewController: UIViewController {
    var mapView:  RVMapView!
    var switcher: UISegmentedControl!
    var actionSheet: UIAlertController!
    let myLocationKeyPath: String = "myLocation"
    let types = [RVGMaps.MapType.normal.rawValue, RVGMaps.MapType.satellite.rawValue, RVGMaps.MapType.hybrid.rawValue, RVGMaps.MapType.terrain.rawValue]
    private var firstLocationUpdated: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    override func loadView() {
        // Creat a GMSCameraPosition that tells the map to display the 
        // coorindate -33.86, 151.20 at zoom level 6
        let latitude: CLLocationDegrees = 37.86
        let longitude: CLLocationDegrees = 119.50
        let zoom: Float = 6.0
        let title = "Portola Valley"
        let snippet = "California"
        
        switcher = UISegmentedControl(items: types)
        switcher.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleTopMargin]
        switcher.selectedSegmentIndex = 0
        self.navigationItem.titleView = switcher
        switcher.addTarget(self, action: #selector(ViewController.didChangeSwitcher(control:)), for: UIControlEvents.valueChanged)
        installActionSheet()
        mapStyleButton()
        mapView = RVGMaps.sharedInstance.mapView(latitude: latitude, longitude: longitude, zoom: zoom)
        if let mapView = self.mapView {

                mapView.settings.compassButton = true
                mapView.settings.myLocationButton = true

        } else {
            print("In \(self.classForCoder).loadView, mapView is nil")
        }

        mapView.addObserver(self, forKeyPath: myLocationKeyPath, options: NSKeyValueObservingOptions.new, context: nil)
        let marker = RVMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title    = title
        marker.snippet  = snippet
        marker.map      = mapView
        view = mapView
    
        mapView.isTrafficEnabled = true
        // Ask for My Location data after the map has already been added to the UI
        DispatchQueue.main.async {
            self.mapView.isMyLocationEnabled = true
        }
    }
    func mapStyleButton() {
        let styleButton = UIBarButtonItem(title: "Style", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.styleButtonTouched(button:)))
        self.navigationItem.rightBarButtonItem = styleButton
    }
    func styleButtonTouched(button: UIBarButtonItem) {
        if let actionSheet = self.actionSheet {
            self.present(actionSheet, animated: true) {
                
            }
        }
    }
    func installActionSheet() {
        actionSheet = UIAlertController(title: "Style", message: "Select a Style", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
            
        }
        actionSheet.addAction(cancelAction)
        let style = RVGMaps.MapStyle.retro
        let retroAction = UIAlertAction(title: style.rawValue, style: .default) { (action: UIAlertAction) in
            if let mapView = self.mapView {
                RVGMaps.sharedInstance.mapStyle(mapStyle: style, callback: { (style , error) in
                    if let error = error {
                        print("In ViewController.installActionSheet, retroAction, \(error.message) \(error.localizedDescription)")
                    } else {
                        mapView.mapStyle = style
                    }
                })
            }
        }
        actionSheet.addAction(retroAction)

        let grayAction = UIAlertAction(title: RVGMaps.MapStyle.grayscale.rawValue, style: .default) { (action: UIAlertAction) in
            let style = RVGMaps.MapStyle.grayscale
            if let mapView = self.mapView {
                RVGMaps.sharedInstance.mapStyle(mapStyle: style, callback: { (style , error) in
                    if let error = error {
                        print("\(error)")
                    } else {
                        mapView.mapStyle = style
                    }
                })
            }
        }
        actionSheet.addAction(grayAction)
        let nightAction = UIAlertAction(title: RVGMaps.MapStyle.night.rawValue, style: .default) { (action: UIAlertAction) in
            let style = RVGMaps.MapStyle.night
            if let mapView = self.mapView {
                RVGMaps.sharedInstance.mapStyle(mapStyle: style, callback: { (style , error) in
                    if let error = error {
                        print("\(error)")
                    } else {
                        mapView.mapStyle = style
                    }
                })
            }
        }
        actionSheet.addAction(nightAction)
        let normalAction = UIAlertAction(title: RVGMaps.MapStyle.normal.rawValue, style: .default) { (action: UIAlertAction) in
            if let mapView = self.mapView {
                mapView.mapStyle = nil
            }
        }
        actionSheet.addAction(normalAction)
        let noPOIsAction = UIAlertAction(title: RVGMaps.MapStyle.noPOIs.rawValue, style: .default) { (action: UIAlertAction) in
            let style = RVGMaps.MapStyle.noPOIs
            if let mapView = self.mapView {
                RVGMaps.sharedInstance.mapStyle(mapStyle: style, callback: { (style, error ) in
                    if let error = error {
                        print("\(error)")
                    } else {
                        mapView.mapStyle = style
                    }
                })
            }
        }
        actionSheet.addAction(noPOIsAction)
    }
    func didChangeSwitcher(control: UISegmentedControl) {
        let index = control.selectedSegmentIndex
        if index >= 0 && index < types.count {
            let rawType = types[index]
            if let type = RVGMaps.MapType(rawValue: rawType) {
                if let mapView = self.mapView {
                    mapView.mapType = type.gmsType
                }
            }
        }
    }


    deinit {
        if let mapView = mapView {
            mapView.removeObserver(self, forKeyPath: myLocationKeyPath, context: nil)
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if !firstLocationUpdated {
            if let change = change {
                if let location = change[NSKeyValueChangeKey.newKey] as? CLLocation {
                    let zoom: Float = 14.0
                    mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: zoom)
                    return
                }
            }
            
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

}
