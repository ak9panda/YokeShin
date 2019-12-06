//
//  SearchMoviesViewController.swift
//  YokeShin
//
//  Created by admin on 25/11/2019.
//  Copyright © 2019 aung. All rights reserved.
//

import UIKit
import RealmSwift

class SearchMoviesViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var collectionViewMovies: UICollectionView!
    @IBOutlet weak var lblNotFound: UILabel!
    
    lazy var activityIndicator : UIActivityIndicatorView = {
        let ui = UIActivityIndicatorView()
        ui.translatesAutoresizingMaskIntoConstraints = false
        ui.stopAnimating()
        ui.isHidden = true
        ui.activityIndicatorViewStyle = UIActivityIndicatorView.Style.whiteLarge
        return ui
    }()
    
    private var searchedResult = [MovieResponse]()
    let realm  = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        lblNotFound.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.becomeFirstResponder()
    }
    
    fileprivate func initView() {
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "enter movie name..."
        
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .always
        definesPresentationContext = true
        // Setup the Scope Bar
        searchController.searchBar.delegate = self
        searchController.searchBar.barStyle = .default
        self.view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        
    }

}

extension SearchMoviesViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = searchedResult[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.identifier, for: indexPath) as? MovieListCollectionViewCell else {
            return UICollectionViewCell()
        }
        let movieVO = MovieResponse.convertToMovieVO(data: movie, realm: realm)
        cell.data = movieVO
        
        return cell
    }
    
    
}

extension SearchMoviesViewController : UICollectionViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let MovieDetailViewController = segue.destination as? MovieDetailViewController {
            if let indexPaths = collectionViewMovies.indexPathsForSelectedItems, indexPaths.count > 0 {
                let movie = searchedResult[indexPaths[0].row]
                MovieDetailViewController.movieId = movie.id ?? 0
            }
        }
    }
}

extension SearchMoviesViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 10;
        return CGSize(width: width, height: width * 1.45)
    }
}

extension SearchMoviesViewController : UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        activityIndicator.startAnimating()
        let searchMovie = searchBar.text ?? ""
        MovieModel.shared.fetchMovieByName(movieName: searchMovie) { [weak self] results in
            self?.searchedResult = results
            
            DispatchQueue.main.async {
                if results.isEmpty {
                    self?.lblNotFound.text = "No movie found with name \"\(searchMovie)\" "
                    self?.lblNotFound.isHidden = false
                    return
                }
                
                results.forEach({ [weak self] (movieInfo) in
                    MovieResponse.saveMovie(data: movieInfo, realm: self!.realm)
                })

                self?.lblNotFound.text = ""
                self?.collectionViewMovies.reloadData()
                
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedResult = [MovieResponse]()
        collectionViewMovies.reloadData()
    }
}
