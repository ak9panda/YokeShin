//
//  BookmarkVO.swift
//  YokeShin
//
//  Created by aung on 11/7/19.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class BookmarkVO : Object {
    dynamic var id : String = UUID().uuidString
    dynamic var movie_id : Int = 0
    dynamic var created_at = Date()
    dynamic var movieDetails : MovieVO?
    
    override static func primaryKey() -> String?{
        return "movie_id"
    }
}

extension BookmarkVO {
    static func saveMovieBookmark(movieId : Int, realm : Realm){
        let movieBookmarkVO = BookmarkVO()
        
        let bookmarkMovie = realm.object(ofType: MovieVO.self, forPrimaryKey: movieId)
        movieBookmarkVO.movie_id = bookmarkMovie?.id ?? 0
        movieBookmarkVO.movieDetails = bookmarkMovie
        
        do{
            try realm.write {
                realm.add(movieBookmarkVO)
            }
        }catch{
            print("Error: \(error.localizedDescription), cannot added to bookmark")
        }
    }
    
    static func deleteMovieBookmark(movieId : Int, realm : Realm) {
        do{
            try realm.write {
                realm.delete(realm.objects(BookmarkVO.self).filter("movie_id=%@",movieId))
            }
        }catch{
            print("Error: \(error.localizedDescription), cannot added to bookmark")
        }
    }
}
