//
//  MovieListResponse.swift
//  YokeShin
//
//  Created by aung on 11/5/19.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation
import RealmSwift

struct MovieListResponse : Codable {
    let page : Int
    let total_results : Int
    let total_pages : Int
    let results : [MovieResponse]
}
