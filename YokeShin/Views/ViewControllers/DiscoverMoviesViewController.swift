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
    
    var movieTags : [String] = ["Now Playing", "Upcoming", "Popular", "Top Rated"]
    
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
        collectionViewMovieLists.reloadData()
        
//        movieList = realm.objects(MovieVO.self).sorted(byKeyPath: "popularity", ascending: true)
//        movieListNotifierToken = movieList?.observe{ [weak self] (changes : RealmCollectionChange) in
//            switch changes {
//            case .initial:
//                self?.collectionViewMovieLists.reloadData()
//                break
//            case .update(_, let deletions, let insertions, let modifications):
//                self?.collectionViewMovieLists.performBatchUpdates({
//                    self?.collectionViewMovieLists.deleteItems(at: deletions.map({ IndexPath(row: $0, section: 0)}))
//                    self?.collectionViewMovieLists.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0)}))
//                    self?.collectionViewMovieLists.reloadItems(at: modifications.map({ IndexPath(row: $0, section: 0)}))
//                }, completion: nil)
//                break
//            case .error(let error):
//                fatalError("\(error)")
//                break;
//            }
//        }
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
            //collectionViewMovieLists.reloadData()
        }
    }
    
    fileprivate func initMovieListFetchRequest() {
        let movieList = realm.objects(MovieVO.self)
        if movieList.isEmpty {
            FetchMovies()
        }else{
            self.movieList = movieList
            //collectionViewMovieLists.reloadData()
        }
    }
    
    fileprivate func FetchMovies() {
        var movieResponses = [MovieResponse]()
        
        if NetworkUtil.checkReachable() == false {
            Alerts.showAlert(VC: self, title: "Error", message: "No Internet Connection!")
            return
        }
        
//        for index in 0...5 {
            MovieModel.shared.fetchTopRatedMovies(pageId: 1) { [weak self] movies in
                movies.forEach{ movie in
                    var data = movie
                    data.movieTag = MovieTag.TOP_RATED
                    movieResponses.append(data)
//                        MovieResponse.saveMovie(data: data, realm: self!.realm)
                }
                MovieModel.shared.fetchPopularMovies(pageId: 1) { [weak self] movies in
                    movies.forEach({ movie in
                        var data = movie
                        data.movieTag = MovieTag.POPULAR
                        movieResponses.append(data)
                    })
                    MovieModel.shared.fetchUpcomingMovies(pageId: 1) { [weak self] movies in
                        movies.forEach({ movie in
                            var data = movie
                            data.movieTag = MovieTag.UPCOMING
                            movieResponses.append(data)
                        })
                        MovieModel.shared.fetchNowplayingMovies(pageId: 1) { [weak self] movies in
                            movies.forEach({ movie in
                                var data = movie
                                data.movieTag = MovieTag.NOW_PLAYING
                                movieResponses.append(data)
                            })
                            
                            DispatchQueue.main.async {
                                movieResponses.forEach({ (movieResponse) in
                                    MovieResponse.saveMovie(data: movieResponse, realm: self!.realm)
                                })
                            }
                        }
                    }
                }
            }
//        }
        
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
            self.FetchMovies()
        }
    }
    
    deinit {
        movieListNotifierToken?.invalidate()
    }
}



extension DiscoverMoviesViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return movieTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let tag = movieTags[section]
        let realmObj = realm.objects(MovieVO.self)//.filter("movie_tag==\(tag)")
        let data = realmObj.filter("movie_tag == %@", tag)
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var selectedmovie : MovieVO?
        let tag = movieTags[indexPath.section]
        let realmObj = realm.objects(MovieVO.self)//.filter("movie_tag==\(tag)")
        let data = realmObj.filter("movie_tag == %@", tag)
        selectedmovie = data[indexPath.row]
//        let movie = movieList?[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.identifier, for: indexPath) as? MovieListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.data = selectedmovie
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let tag = movieTags[indexPath.section]
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as? TitleSupplementaryView{
            sectionHeader.lblHeader.text = MovieTag(rawValue: tag).map { $0.rawValue }
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
                let tag = movieTags[indexPaths[0].section]
                let realmObj = realm.objects(MovieVO.self)//.filter("movie_tag==\(tag)")
                let data = realmObj.filter("movie_tag == %@", tag)
                let movie = data[indexPaths[0].row]
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
