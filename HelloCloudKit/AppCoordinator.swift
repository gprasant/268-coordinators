//
//  AppCoordinator.swift
//  HelloCloudKit
//
//  Created by Prasanth Guruprasad on 3/17/18.
//  Copyright © 2018 NSScreencast. All rights reserved.
//

import UIKit

class AppCoordinator : RestaurantsViewControllerDelegate, RestaurantViewControllerDelegate {

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let restaurantsVC = navigationController.topViewController as! RestaurantsViewController
        restaurantsVC.delegate = self
    }

    func didSelect(restaurant: Restaurant) {
        let restaurantDetail = RestaurantViewController.makeFromStoryboard()
        restaurantDetail.restaurant = restaurant
        restaurantDetail.restaurantDelegate = self
        navigationController.pushViewController(restaurantDetail, animated: true)
    }

    func addReviewTapped(_ vc: RestaurantViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "AddReviewNavigationController") as! UINavigationController
        let reviewVC = nav.topViewController as! ReviewViewController
        reviewVC.addReviewBlock = { [weak self] rvc in
            //  init(author: String, comment: String, rating: Float, restaurantID: CKRecordID)
            let review = Review(author: rvc.nameTextField.text ?? "",
                                comment: rvc.commentTextView.text,
                                rating: Float(rvc.ratingView.value),
                                restaurantID: vc.restaurantID)
            Restaurants.add(review: review)
            self?.navigationController.dismiss(animated: true) {
                vc.insertReview(review)
            }
        }

        navigationController.present(nav, animated: true)
    }

    func photosTapped(_ vc: RestaurantViewController) {
        let photosVC = PhotosViewController.makeFromStoryBoard()
        photosVC.restaurantID = vc.restaurantID
        navigationController.pushViewController(photosVC, animated: true)
    }
}
