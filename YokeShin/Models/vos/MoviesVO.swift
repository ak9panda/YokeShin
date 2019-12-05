//
//  Movies.swift
//  YokeShin
//
//  Created by aung on 10/27/19.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class MovieVO: Object {
    dynamic var popularity : Double = 0
    dynamic var vote_count : Int = 0
    dynamic var video : Bool = false
    dynamic var poster_path : String?
    dynamic var id : Int = 0
    dynamic var adult : Bool = false
    dynamic var backdrop_path : String?
    dynamic var original_language : String?
    dynamic var original_title : String?
    dynamic var title : String?
    dynamic var vote_average : Double = 0
    dynamic var overview : String?
    dynamic var release_date : String?
    dynamic var budget : Int = 0
    dynamic var homepage : String?
    dynamic var imdb_id : String?
    dynamic var revenue : Int = 0
    dynamic var runtime : Int = 0
    dynamic var tagline : String?
    dynamic var movie_tag : String?
    var genres = List<MovieGenreVO>()
    
    override static func primaryKey() -> String?{
        return "id"
    }
    
    override static func ignoredProperties() -> [String]{
        return ["genre_ids"]
    }
}

enum MovieTag : String {
    case NOW_PLAYING = "Now Playing"
    case POPULAR = "Popular"
    case TOP_RATED = "Top Rated"
    case UPCOMING = "Upcoming"
    case NOT_LISTED = "Not Listed"
}

extension MovieVO {
    static func getMovieByID (movieid : Int, realm : Realm) -> MovieVO? {
        return realm.object(ofType: MovieVO.self, forPrimaryKey: movieid)
    }
}


