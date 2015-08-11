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

class CoffeeShopPinDetailView : UIView {
	@IBOutlet var hoursLabel: UILabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var departureLabel: UILabel!
	@IBOutlet var arrivalLabel: UILabel!
	
	@IBOutlet var timeStackView: UIStackView!
	var coffeeShop: CoffeeShop?
	
	@IBOutlet var openCloseStatusImage: UIImageView!
	@IBOutlet var priceGuideImages: [UIImageView]!
	
	@IBOutlet var ratingImages: [UIImageView]!
	var view: UIView!
	var nibName: String = "CoffeeShopPinDetailView"
	var currentLocation:CLLocationCoordinate2D?
	
	private static var dateFormatter = NSDateFormatter()
	
	override func awakeFromNib() {
		timeStackView.hidden = true
	}
	
	//MARK: Update UI
	func updateDetailView(coffeeShop: CoffeeShop) {
		self.coffeeShop = coffeeShop
		
		descriptionLabel.text = coffeeShop.details
		updateRating(coffeeShop.rating)
		updatePriceGuide(coffeeShop.priceGuide)
		updateShopAvailability(coffeeShop)
		
		CoffeeShopPinDetailView.dateFormatter.dateFormat = "h:mm a"
		let startTime = CoffeeShopPinDetailView.dateFormatter.stringFromDate(coffeeShop.startTime!)
		let endTime = CoffeeShopPinDetailView.dateFormatter.stringFromDate(coffeeShop.endTime!)
		hoursLabel.text = "\(startTime) - \(endTime)"
	}
	
	func updateRating(rating: CoffeeRating) {
		var count = rating.value
		for imageView in ratingImages {
			if (count != 0) {
				imageView.hidden = false
				count--
			} else {
				imageView.hidden = true
			}
		}
	}
	
	func updatePriceGuide(priceGuide: PriceGuide) {
		var count = priceGuide.rawValue
		for imageView in priceGuideImages {
			if (count != 0) {
				imageView.hidden = false
				count--
			} else {
				imageView.hidden = true
			}
		}
	}
	
	func updateShopAvailability(coffeeShop: CoffeeShop) {
		let calendar = NSCalendar.currentCalendar()
		let nowComponents = calendar.components([.Hour, .Minute, .Second], fromDate: NSDate())
		
		guard let startTime = coffeeShop.startTime else {
			print("No Start Time!")
			return
		}
		
		guard let endTime = coffeeShop.endTime else {
			print("No End Time!")
			return
		}
		
		let startTimeComponents = calendar.components([.Hour, .Minute, .Second], fromDate: startTime)
		let endTimeComponents = calendar.components([.Hour, .Minute, .Second], fromDate: endTime)
		
		let isEarlier = nowComponents.hour < startTimeComponents.hour //Checks to see if current time is before opening
		//Check to see if current time is after closing
		let isLate = nowComponents.hour > endTimeComponents.hour || nowComponents.hour == endTimeComponents.hour && (startTimeComponents.minute > 0 || startTimeComponents.second > 0)
		
		if (isEarlier || isLate) {
				openCloseStatusImage.image = UIImage(named: "cafétransit_icon_closed")
		} else {
				openCloseStatusImage.image = UIImage(named: "cafétransit_icon_open")
		}
	}
	
	func updateEstimatedTimeLabels(response: MKETAResponse?) {
		if let response = response {
			CoffeeShopPinDetailView.dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
			
			let arrivalTimeString = CoffeeShopPinDetailView.dateFormatter.stringFromDate(response.expectedArrivalDate)
			let departureTimeString = CoffeeShopPinDetailView.dateFormatter.stringFromDate(response.expectedDepartureDate)
			
			let departureTime = String(format: "%@", departureTimeString)
			let arrivalTime = String(format: "%@", arrivalTimeString)
			
			self.departureLabel.text = departureTime
			self.arrivalLabel.text = arrivalTime
		}
	}
	
	//MARK: Tapping Icons
	@IBAction func phoneTapped(sender: AnyObject) {
		if let phone = self.coffeeShop?.phone {
			let phoneString = "tel://" + phone
			if let url = NSURL(string: phoneString) {
				UIApplication.sharedApplication().openURL(url)
			}
		}
	}
	
	@IBAction func transitTapped(sender: AnyObject) {
		if let location = self.coffeeShop?.location {
			openInMapTransit(location)
		}
	}
	
	@IBAction func internetTapped(sender: AnyObject) {
		if let website = self.coffeeShop?.yelpWebsite {
			UIApplication.sharedApplication().openURL(NSURL(string: website)!)
		}
	}
	
	private func animateView(view: UIView, toHidden hidden: Bool) {
		UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10.0, options: UIViewAnimationOptions(), animations: { () -> Void in
			view.hidden = hidden
			}, completion: nil)
	}
	
	@IBAction func timeTapped(sender: AnyObject) {
		if timeStackView.hidden {
			animateView(timeStackView, toHidden: false)
			setTransitEstimatedTimes()
		} else {
			animateView(timeStackView, toHidden: true)
		}
	}
	
	private func animateView(view: UIView,hidden: Bool) {
		UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: UIViewAnimationOptions(), animations: { () -> Void in
			view.hidden = hidden
			}, completion: nil)
	}
	
	//MARK: Transit Helpers
	func openInMapTransit(coord:CLLocationCoordinate2D) {
		let placemark = MKPlacemark(coordinate: coord, addressDictionary: nil)
		let mapItem = MKMapItem(placemark: placemark)
		let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit]
		mapItem.openInMapsWithLaunchOptions(launchOptions)
	}
	
	func setTransitEstimatedTimes() {
		if let currentLocation = currentLocation {
			let request = MKDirectionsRequest()
			let source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation, addressDictionary: nil))
			let destination = MKMapItem(placemark: MKPlacemark(coordinate: (self.coffeeShop?.location)!, addressDictionary: nil))
			request.source = source
			request.destination = destination
			//Set Transport Type to be Transit
			request.transportType = MKDirectionsTransportType.Transit
			
			let directions = MKDirections(request: request)
			directions.calculateETAWithCompletionHandler { response, error in
				if let error = error {
					print(error.localizedDescription)
				} else {
					self.updateEstimatedTimeLabels(response)
				}
			}
		}
	}
}

extension UIView {
	class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
		return UINib(
			nibName: nibNamed,
			bundle: bundle
			).instantiateWithOwner(nil, options: nil)[0] as? UIView
	}
}
