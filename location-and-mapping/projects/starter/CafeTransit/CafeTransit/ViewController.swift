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
import MapKit

class ViewController: UIViewController {
	
	//Make sure the user set's up custom location to be in San Francisco.
	
	@IBOutlet var mapView: MKMapView!
	
	var coffeeShops = [CoffeeShop]()
	override func viewDidLoad() {
		super.viewDidLoad()
		
		customizeMap()
		setupMapData()
		
	}
	
	//MARK: Setup
	func customizeMap() {
		mapView.showsTraffic = false
		mapView.showsCompass = false
		mapView.showsScale = false
		mapView.showsPointsOfInterest = true
		mapView.showsBuildings = false
		
		//For Tutorial Purposes, only focusing on San Francisco for now.
		let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
		centerMap(mapView, atPosition: sanFrancisco)
	}
	
	func setupMapData() {
		if let seedCoffeeShops = CoffeeShop.loadDefaultCoffeeShops() {
			coffeeShops += seedCoffeeShops
			coffeeShops = coffeeShops.sort { $0.name < $1.name }
		}
		
		for coffeeshop in coffeeShops {
			let annotation = CoffeeShopPin(coffeeshop: coffeeshop)
			mapView.addAnnotation(annotation)
		}
	}
	
	private func centerMap(map: MKMapView?, atPosition position: CLLocationCoordinate2D?) {
		guard let map = map,
			let position = position else {
				return
		}
		map.setCenterCoordinate(position, animated: true)
		let zoomRegion = MKCoordinateRegionMakeWithDistance(position, 10000, 10000)
		map.setRegion(zoomRegion, animated: true)
	}
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let identifier = "coffeeShopPin"
		var view: MKPinAnnotationView
		guard let annotation = annotation as? CoffeeShopPin else {
			return nil
		}
		
		guard let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView else {
			view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			view.canShowCallout = true
			view.pinTintColor = UIColor.redColor()
			return view
		}
		//reuse
		dequeuedView.annotation = annotation
		view = dequeuedView
		view.pinTintColor = UIColor.redColor()
		return view
	}
}

