//
//  MovieGenreResponse.swift
//  YokeShin
//
//  Created by aung on 11/5/19.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation
import RealmSwift

struct MovieGenreResponse : Codable {
    let id : Int
    let name : String
    
    static func saveMovieGenre(data : MovieGenreResponse, realm: Realm) {
        
        //TODO: Implement Save Realm object MovieGenreVO
        let movieGenreVO = MovieGenreVO()
        movieGenreVO.id = data.id
        movieGenreVO.name = data.name
        
        do{
            try realm.write {
                realm.add(movieGenreVO)
            }
        }catch{
            print("Error: \(error.localizedDescription), cannot save MovieGenre response to realm")
        }
    }
}
