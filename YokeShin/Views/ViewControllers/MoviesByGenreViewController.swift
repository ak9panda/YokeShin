//
//  MoviesByGenreViewController.swift
//  YokeShin
//
//  Created by admin on 25/11/2019.
//  Copyright © 2019 aung. All rights reserved.
//

import UIKit
import RealmSwift

class MoviesByGenreViewController: UIViewController {

    @IBOutlet weak var CollectionViewMovieList: UICollectionView!
    
    let realm = try! Realm()
    
    var genreMovieList : MovieGenreVO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func initView() {
//        CollectionViewMovieList.dataSource = self
//        CollectionViewMovieList.delegate = self
    }
}

extension MoviesByGenreViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genreMovieList?.movies.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = genreMovieList?.movies[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.identifier, for: indexPath) as? MovieListCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.data = movie
        return cell
    }
}

extension MoviesByGenreViewController: UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension MoviesByGenreViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 10;
        return CGSize(width: width, height: width * 1.45)
    }
}
