//
//  DiscoverMoviesViewController.swift
//  YokeShin
//
//  Created by aung on 10/26/19.
//  Copyright © 2019 aung. All rights reserved.
//

import UIKit
import RealmSwift

class DiscoverMoviesViewController: UIViewController {
    
    @IBOutlet weak var collectionViewMovieLists: UICollectionView!
    
    let realm = try! Realm()
    
    var movieList : Results<MovieVO>?
    
    private var movieListNotifierToken : NotificationToken?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(handleRefresh(_:)),for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        
        initMovieListFetchRequest()
        
        realmNotiObserver()
    }

    func initView() {
//        collectionViewMovieLists.delegate = self
//        collectionViewMovieLists.dataSource = self
        //add refresh control to collection view
        collectionViewMovieLists.addSubview(refreshControl)
    }
    
    func realmNotiObserver() {
        movieList = realm.objects(MovieVO.self).sorted(byKeyPath: "popularity", ascending: true)
        movieListNotifierToken = movieList?.observe{ [weak self] (changes : RealmCollectionChange) in
            switch changes {
            case .initial:
                self?.collectionViewMovieLists.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                self?.collectionViewMovieLists.performBatchUpdates({
                    self?.collectionViewMovieLists.deleteItems(at: deletions.map({ IndexPath(row: $0, section: 0)}))
                    self?.collectionViewMovieLists.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0)}))
                    self?.collectionViewMovieLists.reloadItems(at: modifications.map({ IndexPath(row: $0, section: 0)}))
                }, completion: nil)
                break
            case .error(let error):
                fatalError("\(error)")
                break;
            }
        }
    }
    
    fileprivate func initMovieListFetchRequest() {
        let movieList = realm.objects(MovieVO.self)
        if movieList.isEmpty {
            MovieModel.shared.fetchPopularMovies{ (movies) in
                movies.forEach({ [weak self] movie in
                    DispatchQueue.main.async {
                        MovieResponse.saveMovie(data: movie, realm: self!.realm)
                    }
                })
            }
        }else{
            self.movieList = movieList
            collectionViewMovieLists.reloadData()
        }
    }
    
    fileprivate func fetchPopularMovies() {
        if NetworkUtil.checkReachable() == false {
            Alerts.showAlert(VC: self, title: "Error", message: "No Internet Connection!")
            return
        }
        for index in 0...5 {
            MovieModel.shared.fetchPopularMovies(pageId: index) { [weak self] movies in
                DispatchQueue.main.async { [weak self] in
                    movies.forEach{ movie in
                        MovieResponse.saveMovie(data: movie, realm: self!.realm)
                    }
                    self?.refreshControl.endRefreshing()
                }
            }
        }
        
    }

    @objc func handleRefresh(_ refreshControl : UIRefreshControl) {
        //delete movie in the list and redownload
        if let movieList = movieList, !movieList.isEmpty {
            movieList.forEach{ movie in
                try! realm.write {
                    print("Deleting \(movie.original_title ?? "xxx")" )
                    realm.delete(movie)
                }
            }
            //refetch movies for update
            self.fetchPopularMovies()
        }
    }
}



extension DiscoverMoviesViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = movieList?[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.identifier, for: indexPath) as? MovieListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.data = movie
        return cell
    }
}

extension DiscoverMoviesViewController : UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension DiscoverMoviesViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 10;
        return CGSize(width: width, height: width * 1.45)
    }
}
