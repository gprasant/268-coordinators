//
//  RestaurantViewController.swift
//  HelloCloudKit
//
//  Created by Ben Scheirman on 3/28/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import UIKit
import CloudKit

protocol RestaurantViewControllerDelegate : class {
    func addReviewTapped(_ vc: RestaurantViewController)
    func photosTapped(_ vc: RestaurantViewController)
}

class RestaurantViewController : UITableViewController {

    weak var restaurantDelegate: RestaurantViewControllerDelegate?

    enum Sections : Int {
        case info
        case reviews
        case count
    }
    
    var restaurant: Restaurant?
    var reviews: [Review] = []

    var restaurantID: CKRecordID {
        return restaurant!.recordID!
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func addReview(_ sender: Any) {
        restaurantDelegate?.addReviewTapped(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
        
        configureUI()
        loadReviews()
    }

    class func makeFromStoryboard() -> RestaurantViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: self)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier) as! RestaurantViewController
        return vc
    }

    
    private func loadReviews() {
        Restaurants.reviews(for: restaurant!) { (reviews, error) in
            if let e = error {
                print("Error fetching reviews: \(e.localizedDescription)")
            } else {
                self.reviews = reviews
                self.tableView.reloadSections([Sections.reviews.rawValue], with: .none)
            }
        }
    }
    
    private func configureUI() {
        guard let restaurant = self.restaurant else { return }
        title = restaurant.name
        if let imageURL = restaurant.imageFileURL {
            let data = try! Data(contentsOf: imageURL)
            imageView.image = UIImage(data: data)
        }
    }
    
    func insertReview(_ review: Review) {
        reviews.insert(review, at: 0)
        let indexPath = IndexPath(row: 0, section: Sections.reviews.rawValue)
        tableView.insertRows(at: [indexPath], with: .top)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Sections.info.rawValue {
            return 2
        } else if section == Sections.reviews.rawValue {
            return reviews.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Sections.info.rawValue {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell") as! AddressCell
                cell.addressLabel.text = restaurant?.address ?? ""
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PhotosCell", for: indexPath)
                return cell
            }
            
        } else {
            let review = reviews[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell") as! ReviewCell
            cell.commentLabel.text = review.comment
            cell.authorLabel.text = review.authorName
            cell.ratingView.value = CGFloat(review.stars)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Sections.info.rawValue && indexPath.row == 1 {
            restaurantDelegate?.photosTapped(self)
        }
    }
}
