//
//  GenreListViewController.swift
//  YokeShin
//
//  Created by admin on 25/11/2019.
//  Copyright © 2019 aung. All rights reserved.
//

import UIKit
import RealmSwift

class GenreListViewController: UIViewController {

    @IBOutlet weak var GenreListTableView: UITableView!
    
    let realm = try! Realm()
    
    var movieGenre : Results<MovieGenreVO>?
    
    var movieGenresNotiToken : NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        realmNotiObserver()
        // Do any additional setup after loading the view.
    }
    
    func initView() {
        GenreListTableView.dataSource = self
        GenreListTableView.delegate = self
        let genreList = realm.objects(MovieGenreVO.self)
        if genreList.isEmpty {
            MovieModel.shared.fetchMovieGenres(completion: { (movieGenre) in
                movieGenre.forEach({ [weak self] movieGenre in
                    DispatchQueue.main.async {
                        MovieGenreResponse.saveMovieGenre(data: movieGenre, realm: self!.realm)
                    }
                })
            })
        }else{
            self.movieGenre = genreList
            GenreListTableView.reloadData()
        }
    }
    
    fileprivate func realmNotiObserver() {
        movieGenre = realm.objects(MovieGenreVO.self).sorted(byKeyPath: "name", ascending: true)
        movieGenresNotiToken = movieGenre?.observe{ [weak self] (changes : RealmCollectionChange) in
            switch changes {
            case .initial:
                self?.GenreListTableView.reloadData()
                break
            
            case .update(_, let deletions, let insertions, let modifications):
                self?.GenreListTableView.beginUpdates()
                
                self?.GenreListTableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                self?.GenreListTableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                self?.GenreListTableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                
                self?.GenreListTableView.endUpdates()
                break
                
            case .error(_):
                fatalError("\(Error.self)")
                break;
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}

extension GenreListViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieGenre?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let genre = movieGenre?[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GenreListTableViewCell.identifier, for: indexPath) as? GenreListTableViewCell else {
            return UITableViewCell()
        }
        cell.lblGenreName.text = genre?.name ?? "undefined"
        cell.selectionStyle = .none
        return cell
    }
    
    
}

extension GenreListViewController : UITableViewDelegate {
    
}
