//  GoogleDataProvider.swift
//  Feed Me
//
/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreLocation
import WebKit

class RVGoogleDataProvider {
    var photoCache = [String:UIImage]()
    var placesTask: URLSessionDataTask?
    var session: URLSession {
        return URLSession.shared
    }
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], callback: @escaping ( _ places: [RVGooglePlace], _ error: RVError? )-> Void) -> ()
    {
        print("In RVGoogleDataProvider.fetch...")
        var urlString = "http://localhost:10000/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        var typesString = types.count > 0 ? types.joined(separator: "|") : "food"
        typesString = "&types=\(typesString)"
        if let typesString = typesString.stringByAddingPercentEncodingForRFC3986() {
        urlString += typesString
       // let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
       // urlString += "&types=\(typesString)"
       // if let urlString = urlString.stringByAddingPercentEncodingForRFC3986() {
            if let url = URL(string: urlString) {
                if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
                    print("In RVGoogleDataProvider, cancel task")
                    task.cancel()
                }
                print("In RVGoogleDataProvider.fetch about to do Query")
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                placesTask = session.dataTask(with: url) {data, response, error in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = error {
                        print("In RVGoogleDataProvider.fetch.... got server error \(error.localizedDescription) for url \(url.absoluteString)")
                        let rvError = RVError(message: "In RVGoogleDatProvider.fetch got server error with URL\n\(url.absoluteString)\n", sourceError: error)
                        callback([RVGooglePlace](), rvError)
                        return
                    } else if let response = response {
                        if let response = response as? HTTPURLResponse {
                            print("Got statusCode of \(response.statusCode)")
                            if response.statusCode == 200 {
                                
                                let placesArray = [RVGooglePlace]()
                                if let data = data {
                                    do {
                                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                                        if let json = json as? [String : AnyObject] {
                                            if let results = json["results"] as? [[String: AnyObject]] {
                                                /*
                                                if let place = results.first {
                                                    for (key, value) in place {
                                                        print("\(key): \(value)")
                                                    }
                                                }
                                                */
                                                for index in 0..<results.count {
                                                    let result = results[index]
                                                    var output = ""
                                                    for (key, value) in result {
                                                        output = "\(output) + \(key), "
                                                        if key == "geometry" {
                                                            if let value = value as? [String : AnyObject] {
                                                                for (key, item) in value {
                                                                   // print("\(key): \(item)")
                                                                    if key == "location" {
                                                                        if let item = item as? [String: Float] {
                                                                        //    print ("\(item.first?.key) Lat is number") /// THIS IS IT.
                                                                        } else if let item = item as? [String : String] {
                                                                            print("Lat is string")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                       // print("\(key): \(value)")
                                                    }
                                                   print("\(index)... \(output)")
                                                    /*
                                                    if let place = result.first {
                                                        print("---------------------\nPlace \(result.count) \(index)... \(place)")
                                                    }
 */

                                                }
 
                                            } else {
                                                print("Did not convert to results")
                                                for (key, value) in json {
                                                    print("\(key): \(value)")
                                                }
                                            }

                                        }
                                    } catch let myJSONError {
                                        print(myJSONError)
                                    }
                                    /*
                                     let json = JSON(data:aData, options:NSJSONReadingOptions.MutableContainers, error:nil)
                                     if let results = json["results"].arrayObject as? [[String : AnyObject]] {
                                     for rawPlace in results {
                                     let place = GooglePlace(dictionary: rawPlace, acceptedTypes: types)
                                     placesArray.append(place)
                                     if let reference = place.photoReference {
                                     self.fetchPhotoFromReference(reference) { image in
                                     place.photo = image
                                     }
                                     }
                                     }
                                     }
                                     */
                                }
                                DispatchQueue.main.async() {
                                    callback(placesArray, nil)
                                }
                                return
                            } else {
                                let error = RVError(message: "In RVGoogleDataProvider.fetch... got bad status code of \(response.statusCode)", sourceError: nil)
                                callback([RVGooglePlace](), error)
                                return
                            }
                        }

                    }
                    let error = RVError(message: "In RVGoogleDataProvider.fetch. no server error but no response", sourceError: nil)
                    callback([RVGooglePlace](), error)
                }
                placesTask?.resume()
            } else {
               print("In RVGoogleDataProvider.fetchPlacesNear... could not create URL from \(urlString)")
            }

        } else {
            print("In RVGoogleDataProvider.fetchPlacesNear... bad URL String")
        }

    }
    
    
    func fetchPhotoFromReference(reference: String, completion: @escaping ((UIImage?) -> Void)) -> () {
        if let photo = photoCache[reference] as UIImage? {
            completion(photo)
        } else {
            let urlString = "http://localhost:10000/maps/api/place/photo?maxwidth=200&photoreference=\(reference)"
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            session.downloadTask(with: NSURL(string: urlString)! as URL) {url, response, error in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let url = url {
                    let downloadedPhoto = UIImage(data: NSData(contentsOf: url)! as Data)
                    self.photoCache[reference] = downloadedPhoto
                    DispatchQueue.main.async() {
                        completion(downloadedPhoto)
                    }
                }
                else {
                    DispatchQueue.main.async() {
                        completion(nil)
                    }
                }
                }.resume()
        }
    }
}
