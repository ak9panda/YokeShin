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
    @IBOutlet weak var lblMovieName: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblMovieDesc: UILabel!
    @IBOutlet weak var lblGenreName: UILabel!
    @IBOutlet weak var lblRatings: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
    
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
        
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.colors = [UIColor(named: "SecondaryColor")?.cgColor ?? UIColor.lightGray.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height/3)

        self.imgCoverViewLarge.layer.insertSublayer(gradient, at: 0)
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
        self.lblMovieName.text = data.original_title
//        self.imgCoverViewSmall.sd_setImage(with: URL(string: "\(API.BASE_IMG_URL)\(data.poster_path ?? "")"), placeholderImage: #imageLiteral(resourceName: "ic_movie"), options:  SDWebImageOptions.progressiveLoad, completed: nil)
        self.lblYear.text = formatDate(dateString: data.release_date ?? "")
        self.lblType.text = " \(data.genres[0].name) "
        self.lblHours.text = formatTime(runtime: data.runtime)
        self.lblMovieDesc.text = data.overview
        if data.genres.count > 0 {
            data.genres.forEach{ genre in
                self.lblGenreName.text = genre.name + " "
            }
        }
        self.lblRatings.text = String(data.vote_average)
        if let _ = realm.object(ofType: BookmarkVO.self, forPrimaryKey: data.id){
            btnBookmark.setImage(UIImage(named: "ic_bookmark_fill"), for: .normal)
        }else{
            btnBookmark.setImage(UIImage(named: "ic_bookmark_empty"), for: .normal)
        }
    }
    
    @IBAction func onTouchBtnClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTouchBookmarkbtn(_ sender: Any) {
        if btnBookmark.imageView?.image == #imageLiteral(resourceName: "ic_bookmark_fill"){
            btnBookmark.setImage(UIImage(named: "ic_bookmark_empty"), for: .normal)
            BookmarkVO.deleteMovieBookmark(movieId: movieId, realm: realm)
        }else{
            btnBookmark.setImage(UIImage(named: "ic_bookmark_fill"), for: .normal)
            BookmarkVO.saveMovieBookmark(movieId: movieId, realm: realm)
        }
    }
    
    func formatDate(dateString: String) -> String {
        if dateString.count > 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: dateString)
            
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "MMM d, yyyy"
            return " \(dateFormatter1.string(from: date ?? Date())) "
        }
        return ""
    }
    
    func formatTime(runtime: Int) -> String {
        let hour = runtime / 60
        let min = runtime % 60
        return " \(hour)hr \(min)min "
    }
}
