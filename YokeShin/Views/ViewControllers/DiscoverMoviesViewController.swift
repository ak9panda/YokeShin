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
    
    var movieGenreList : Results<MovieGenreVO>?
    
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
        
        //Remove all cached data in URL Response
        URLCache.shared.removeAllCachedResponses()
        
        initGenreListFetchRequest()
        
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
    
    fileprivate func initGenreListFetchRequest() {
        let genres = realm.objects(MovieGenreVO.self)
        if genres.isEmpty {
            MovieModel.shared.fetchMovieGenres{ genres in
                genres.forEach { [weak self] genre in
                    DispatchQueue.main.async {
                        MovieGenreResponse.saveMovieGenre(data: genre, realm: self!.realm)
                    }
                }
            }
        }else{
            self.movieGenreList = genres
            collectionViewMovieLists.reloadData()
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
            //collectionViewMovieLists.reloadData()
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
    
    deinit {
        movieListNotifierToken?.invalidate()
    }
}



extension DiscoverMoviesViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return movieGenreList?.count ?? 0
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let genres = movieGenreList?[indexPath.section]
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as? TitleSupplementaryView{
            sectionHeader.lblHeader.text = genres?.name
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

extension DiscoverMoviesViewController : UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let MovieDetailViewController = segue.destination as? MovieDetailViewController {
            if let indexPaths = collectionViewMovieLists.indexPathsForSelectedItems, indexPaths.count > 0 {
                let selectedIndexPath = indexPaths[0]
                let movie = movieList![selectedIndexPath.row]
                MovieDetailViewController.movieId = Int(movie.id)
            }
        }
    }
}

extension DiscoverMoviesViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 10;
        return CGSize(width: width, height: width * 1.45)
    }
}
