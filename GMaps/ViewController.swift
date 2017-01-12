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

extension ViewController: GMSMapViewDelegate{
    
    /**
     * Called before the camera on the map changes, either due to a gesture,
     * animation (e.g., by a user tapping on the "My Location" button) or by being
     * updated explicitly via the camera or a zero-length animation on layer.
     *
     * @param gesture If YES, this is occuring due to a user gesture.
     */
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {}
    
    
    /**
     * Called repeatedly during any animations or gestures on the map (or once, if
     * the camera is explicitly set). This may not be called for all intermediate
     * camera positions. It is always called for the final position of an animation
     * or gesture.
     */
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //print("In \(self.classForCoder).didChange \(position)")
    }
    
    
    /**
     * Called when the map becomes idle, after any outstanding gestures or
     * animations have completed (or after the camera has been explicitly set).
     */
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //print("In \(self.classForCoder).idleAt \(position)")
    }
    
    
    /**
     * Called after a tap gesture at a particular coordinate, but only if a marker
     * was not tapped.  This is called before deselecting any currently selected
     * marker (the implicit action for tapping on the map).
     */
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("In \(self.classForCoder).didTapAt \(coordinate)")
    }
    
    
    /**
     * Called after a long-press gesture at a particular coordinate.
     *
     * @param mapView The map view that was tapped.
     * @param coordinate The location that was tapped.
     */
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print("In \(self.classForCoder).didLongPressAt \(coordinate)")
        RVGeocoder.sharedInstance.reverseGeocodeCoordinate(coordinate) { (response: GMSReverseGeocodeResponse?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let response = response {
                if let results: [GMSAddress] = response.results() {
                    print("In \(self.classForCoder).didLongPress reverse Geocode response, have \(results.count) results")
                    if let address: GMSAddress = results.first {
                        print("In \(self.classForCoder).didLongPressAt reverseGeocode result first is \(address)")
                        let marker = RVMarker(position: address.coordinate)
                        if let lines = address.lines {
                            if let first: String = lines.first {
                                marker.title = first // address
                            }
                            if lines.count > 1 {
                                marker.snippet = lines[1] // City, State, Zip
                            }
                            // locality: La Honda,  administrativeArea: California,, postalCode: 94020, country: United States
                            // thoroughfare: 25718-25778 Moody Road
                        }
                        marker.appearAnimation = kGMSMarkerAnimationPop
                        marker.map = mapView
                    }
                } else {
                    print("In \(self.classForCoder).didLongPress reverseGeocode response, no reverse geoCode at \(coordinate)")
                }
            } else {
                print("In \(self.classForCoder).didLongPress at \(coordinate) no error but no result to reverse geocode at \(coordinate)")
            }
        }
    }
    /**
     * Called after a marker has been tapped.
     *
     * @param mapView The map view that was tapped.
     * @param marker The marker that was tapped.
     * @return YES if this delegate handled the tap event, which prevents the map
     *         from performing its default selection behavior, and NO if the map
     *         should continue with its default selection behavior.
     */
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var returnValue: Bool = true
        print("In ViewController.didTap Marker")
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0) // 3 section animation
        var zoom: Float                     = 10.0
        var bearing: CLLocationDirection    = 50.0
        var viewingAngle: Double            = 60.0
        if let sydneyMarker = self.sydneyMarker {
            if sydneyMarker == marker {
                print("ViewController.didTap Sydney Marker")
                zoom = 9.0
                bearing = 0
                viewingAngle = 0.0
            }

        } else if let _ = self.santaMarker {
            print("ViewController.didTap Santa Marker")
        }
        let camera = GMSCameraPosition(target: marker.position, zoom: zoom, bearing: bearing, viewingAngle: viewingAngle)
        if let mapView = self.mapView {
            mapView.animate(to: camera)
        }
        CATransaction.commit()
        // Default market has an InfoWIndow so return false to allow marketInfoWindo to fire.
        // Also check that the market isn't already selected so that the InfoWindow doesn't close
        if let mapView = self.mapView {
            if let santaMarker = self.santaMarker {
                if marker == santaMarker {
                    if mapView.selectedMarker != santaMarker {
                        returnValue = false
                    }
                } else if let sydneyMarker = self.sydneyMarker {
                    if marker == sydneyMarker {
                        if mapView.selectedMarker != sydneyMarker {
                            returnValue = false
                        }
                    }
                }
            }
        }
        // The Tap has been handled so return true
        print("In \(self.classForCoder).didTap, return value is: [\(returnValue)]")
       // return returnValue
        return false
    }
    
    
    /**
     * Called after a marker's info window has been tapped.
     */
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let _  = self.santaMarker {
            print("In \(self.classForCoder).didTapInfoWIndowOf ... santaMarker")
        } else if let _ = self.sydneyMarker {
            print("In \(self.classForCoder).didTapInfoWIndowOf ... Sydney Marker")
        } else {
            print("In \(self.classForCoder).didTapInfoWIndowOf ... Some Other Marker")
        }
    }
    
    
    /**
     * Called after a marker's info window has been long pressed.
     */
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        if let _  = self.santaMarker {
            print("In \(self.classForCoder).didLongPressInfoWindowOf ... santaMarker")
        } else if let _ = self.sydneyMarker {
            print("In \(self.classForCoder).didLongPressInfoWindowOf ... Sydney Marker")
        } else {
            print("In \(self.classForCoder).didLongPressInfoWindowOf ... Some Other Marker")
        }
    }
    
    
    /**
     * Called after an overlay has been tapped.
     * This method is not called for taps on markers.
     *
     * @param mapView The map view that was tapped.
     * @param overlay The overlay that was tapped.
     */
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {}
    
    
    /**
     *  Called after a POI has been tapped.
     *
     * @param mapView The map view that was tapped.
     * @param placeID The placeID of the POI that was tapped.
     * @param name The name of the POI that was tapped.
     * @param location The location of the POI that was tapped.
     */
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {}
    
    
    /**
     * Called when a marker is about to become selected, and provides an optional
     * custom info window to use for that marker if this method returns a UIView.
     * If you change this view after this method is called, those changes will not
     * necessarily be reflected in the rendered version.
     *
     * The returned UIView must not have bounds greater than 500 points on either
     * dimension.  As there is only one info window shown at any time, the returned
     * view may be reused between other info windows.
     *
     * Removing the marker from the map or changing the map's selected marker during
     * this call results in undefined behavior.
     *
     * @return The custom info window for the specified marker, or nil for default
     */
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if let santaMarker = self.santaMarker {
            if marker == santaMarker {
                if let image = UIImage(named: "popup_santa") {
                    return UIImageView(image: image)
                }
            }
        }

        return nil
    }
    /**
     * Called when mapView:markerInfoWindow: returns nil. If this method returns a
     * view, it will be placed within the default info window frame. If this method
     * returns nil, then the default rendering will be used instead.
     *
     * @param mapView The map view that was pressed.
     * @param marker The marker that was pressed.
     * @return The custom view to display as contents in the info window, or nil to
     * use the default content rendering instead
     */
    // func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {}
    
    
    /**
     * Called when the marker's info window is closed.
     */
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {}
    
    
    /**
     * Called when dragging has been initiated on a marker.
     */
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("In \(self.classForCoder).didBeginDragging marker")
    }
    
    
    /**
     * Called after dragging of a marker ended.
     */
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
                print("In \(self.classForCoder).didEndDragging marker")
    }
    
    
    /**
     * Called while a marker is dragged.
     */
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {}
    
    
    /**
     * Called when the My Location button is tapped.
     *
     * @return YES if the listener has consumed the event (i.e., the default behavior should not occur),
     *         NO otherwise (i.e., the default behavior should occur). The default behavior is for the
     *         camera to move such that it is centered on the user location.
     */
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        print("In \(self.classForCoder).didTapMyLocationButton")
        return false
    }
    
    
    /**
     * Called when tiles have just been requested or labels have just started rendering.
     */
    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {}
    
    
    /**
     * Called when all tiles have been loaded (or failed permanently) and labels have been rendered.
     */
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {}
    
    
    /**
     * Called when map is stable (tiles loaded, labels rendered, camera idle) and overlay objects have
     * been rendered.
     */
    func mapViewSnapshotReady(_ mapView: GMSMapView) {
        print("In \(self.classForCoder).mapViewSnapshotReady ----------------")
    }
}
class ViewController: UIViewController {
    var santaMarker: RVMarker!
    var sydneyMarker: RVMarker!
    var mapView:  RVMapView!
    var switcher: UISegmentedControl!
    var actionSheet: UIAlertController!
    let locationManager = CLLocationManager()
    let myLocationKeyPath: String = "myLocation"
    let types = [RVGMaps.MapType.normal.rawValue, RVGMaps.MapType.satellite.rawValue, RVGMaps.MapType.hybrid.rawValue, RVGMaps.MapType.terrain.rawValue]
    private var firstLocationUpdated: Bool = false
    var markerCount: Int = 0

    func installSantaMarker() {
        santaMarker = RVMarker(position: CLLocationCoordinate2DMake(37.8, -122.0))
        if let image = UIImage(named: "arrow.png") {
            santaMarker.icon = image
        }
        if let mapView = self.mapView {
            santaMarker.map = mapView
        }
    }
    func installSydneyMarker() {
        sydneyMarker = RVMarker(position: CLLocationCoordinate2DMake(37.7, -122.3))
        sydneyMarker.title = "Sydney"
        if let image = UIImage(named: "glow-marker.png") {
            sydneyMarker.icon = image
        }
        if let mapView = self.mapView {
            sydneyMarker.map = mapView
        }
    }
    override func loadView() {
    //    let _ = RVLocation.sharedInstance
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // Creat a GMSCameraPosition that tells the map to display the 
        // coorindate -33.86, 151.20 at zoom level 6
        let latitude: CLLocationDegrees = 37.86
        let longitude: CLLocationDegrees = -122.4
        let zoom: Float = 6.0

        
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

        view = mapView
        mapView.delegate = self
        mapView.isTrafficEnabled = true
        // Ask for My Location data after the map has already been added to the UI
        DispatchQueue.main.async {
            self.mapView.isMyLocationEnabled = true
            self.addDefaultMarkers()
        }

    }
    func setupGeocoder() {
        
    }
    func addDefaultMarkers() {
        installSantaMarker()
        installSydneyMarker()
        
        let title = "Portola Valley"
        let snippet = "California"
        let latitude: CLLocationDegrees = 37.86
        let longitude: CLLocationDegrees = -122.4
        let marker = RVMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        marker.title    = title
        marker.snippet  = snippet
        marker.map      = mapView
    }
    func mapStyleButton() {
        let styleButton = UIBarButtonItem(title: "Style", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.styleButtonTouched(button:)))
        //self.navigationItem.rightBarButtonItem = styleButton
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add , target: self , action: #selector(ViewController.addButtonTouched(button:)))
        addButton.accessibilityHint = "Add Markers"
        self.navigationItem.rightBarButtonItems = [styleButton, addButton]
     //   let clearButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel , target: self , action: #selector(ViewController.clearButtonTouched(button:)))
        let clearButton = UIBarButtonItem(title: "Clear", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.clearButtonTouched(button:)))
        self.navigationItem.leftBarButtonItems = [clearButton]
        
    }

    func addButtonTouched(button: UIBarButtonItem) {
        for index in (0..<10) {
            // Add a market every 0.25 seconds for the next ten markets, randomly within the bounds of the cmaer as it is at that point
            let delayInSeconds: TimeInterval = Double(index) * 0.25
            Timer.scheduledTimer(withTimeInterval: delayInSeconds, repeats: false, block: { (timer) in
                if let mapView = self.mapView {
                    let region: GMSVisibleRegion = mapView.projection.visibleRegion()
                    let bounds = GMSCoordinateBounds(region: region)
                    self.addMarkerInBounds(bounds: bounds)
                }
            })
        }
    }
    func clearButtonTouched(button: UIBarButtonItem) {
        if let mapView = self.mapView{
            mapView.clear()
            addDefaultMarkers()
        }
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
        print("In ViewCOntroller.observeValue \(keyPath) ========================")
        
        if !firstLocationUpdated {
            /*
            if let change = change {
                if let location = change[NSKeyValueChangeKey.newKey] as? CLLocation {
                    let zoom: Float = 14.0
                   // mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: zoom) // myLocation
                    return
                }
            }
*/
            
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

}
extension ViewController {
    func randf() -> CLLocationDegrees {
        return CLLocationDegrees(Double(arc4random())) / 0x100000000
    }
    func addMarkerInBounds(bounds: GMSCoordinateBounds) {
        let latitude: CLLocationDegrees = bounds.southWest.latitude + randf() * (bounds.northEast.latitude - bounds.southWest.latitude)
        // If the visible region crosses the antimeridian (the right-most point is "smaller" then the left-most point), adjust the longitude accordingly
        let offset: Bool = (bounds.northEast.longitude < bounds.southWest.longitude)
        var longitude: CLLocationDegrees = bounds.southWest.longitude + randf() * (bounds.northEast.longitude - bounds.southWest.longitude + (offset ? 360 : 0))
        if (longitude > 180.0) {
            longitude = longitude - 360.0
        }
        let color = UIColor(hue: CGFloat(randf()), saturation: 1.0 , brightness: 1.0 , alpha: 1.0 )
        let position: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude , longitude)
        let marker = RVMarker(position: position)
        marker.title = "Marker: \(markerCount)"
        markerCount = markerCount + 1
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = RVMarker.markerImage(with: color)
        marker.rotation = (randf() - 0.5) * 20 // rotate between -10 and + 10 degrees
        if let mapView = self.mapView {
            marker.map = mapView
        }
        
    }
    
}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("In \(self.classForCoder).didChangeAuthorization, authorized")
            locationManager.startUpdatingLocation()
        } else {
            print("In \(self.classForCoder).didChangeAuthorization, not Authorized")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 11, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}
