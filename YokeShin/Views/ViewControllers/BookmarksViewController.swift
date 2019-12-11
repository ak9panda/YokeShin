//
//  BookmarksViewController.swift
//  YokeShin
//
//  Created by admin on 25/11/2019.
//  Copyright © 2019 aung. All rights reserved.
//

import UIKit
import RealmSwift

class BookmarksViewController: UIViewController {

    @IBOutlet weak var collectionViewMovies: UICollectionView!
    
    let realm = try! Realm()
    var bookmarkNotification : NotificationToken?
    var bookmarkMovies : Results<BookmarkVO>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Saved Movies"
    }
    
    func initView() {
        bookmarkMovies = realm.objects(BookmarkVO.self).sorted(byKeyPath: "movie_id", ascending: true)
        bookmarkNotification = bookmarkMovies?.observe{ [weak self] (changes : RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self?.collectionViewMovies.reloadData()
                break;
            case .update(_, let deletions, let insertions, let modifications):
                self?.collectionViewMovies.reloadData()
                break;
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break;
            }
        }
    }
}

extension BookmarksViewController : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarkMovies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let bookmark = bookmarkMovies?[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.identifier, for: indexPath) as? MovieListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.data = bookmark?.movieDetails
        
        return cell
    }
}

extension BookmarksViewController : UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let movieDeatilVC = segue.destination as? MovieDetailViewController {
            if let indexPath = collectionViewMovies.indexPathsForSelectedItems, indexPath.count > 0 {
                let selectedIndexPath = indexPath[0]
                let movie = bookmarkMovies?[selectedIndexPath.row]
                movieDeatilVC.movieId = movie?.movie_id ?? 0
            }
        }
    }
}

extension BookmarksViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 10;
        return CGSize(width: width, height: width * 1.45)
    }
}
