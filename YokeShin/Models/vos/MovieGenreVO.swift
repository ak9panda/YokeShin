//
//  MovieGenereVO.swift
//  YokeShin
//
//  Created by aung on 11/5/19.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class MovieGenreVO : Object {
    dynamic var id : Int = 0
    dynamic var name : String = ""
    let movies = LinkingObjects(fromType: MovieVO.self, property: "genres")
    
    override static func primaryKey() -> String?{
        return "id"
    }
}

extension MovieGenreVO {
    static func getMovieGenreVOById (genreId : Int, realm : Realm) -> MovieGenreVO? {
        return realm.object(ofType: MovieGenreVO.self, forPrimaryKey: genreId)
    }
}
