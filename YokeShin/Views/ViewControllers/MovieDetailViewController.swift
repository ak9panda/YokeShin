//
//  MovieDetailViewController.swift
//  YokeShin
//
//  Created by admin on 25/11/2019.
//  Copyright © 2019 aung. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var imgCoverViewLarge: UIImageView!
    @IBOutlet weak var imgCoverViewSmall: UIImageView!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblMovieDesc: UILabel!
    @IBOutlet weak var lblGenreName: UILabel!
    @IBOutlet weak var lblRatings: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    
    var movieId : Int = 0
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.intiView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func intiView() {
        navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isTranslucent = true
        if let data = MovieVO.getMovieByID(movieid: movieId, realm: realm) {
            self.bindDataToView(data: data)
        }
    }
    
    fileprivate func fetchMoviebyID(movieId : Int) {
        MovieModel.shared.fetchMovieDetails(movieId: movieId) { [weak self] movieDetails in
            DispatchQueue.main.async {
                self?.bindDataToView(data: MovieResponse.convertToMovieVO(data: movieDetails, realm: self!.realm))
            }
        }
    }
    
    fileprivate func bindDataToView(data : MovieVO) {
        self.imgCoverViewLarge.sd_setImage(with: URL(string: "\(API.BASE_IMG_URL)\(data.poster_path ?? "")"), placeholderImage: #imageLiteral(resourceName: "ic_movie"), options:  SDWebImageOptions.progressiveLoad, completed: nil)
        self.imgCoverViewSmall.sd_setImage(with: URL(string: "\(API.BASE_IMG_URL)\(data.poster_path ?? "")"), placeholderImage: #imageLiteral(resourceName: "ic_movie"), options:  SDWebImageOptions.progressiveLoad, completed: nil)
        self.lblYear.text = data.release_date
        self.lblType.text = data.genres[0].name
        self.lblHours.text = String(data.runtime)
        self.lblMovieDesc.text = data.overview
        if data.genres.count > 0 {
            data.genres.forEach{ genre in
                self.lblGenreName.text = genre.name + " "
            }
        }
        self.lblRatings.text = String(data.vote_average)
    }
    @IBAction func onTouchBtnClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
