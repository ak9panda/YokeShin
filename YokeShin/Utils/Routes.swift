//
//  Routes.swift
//  YokeShin
//
//  Created by aung on 11/5/19.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation

class Routes {
    static let ROUTE_MOVIE_GENRES = "\(API.BASE_URL)/genre/movie/list?api_key=\(API.KEY)"
    static let ROUTE_TOP_RATED_MOVIES = "\(API.BASE_URL)/movie/top_rated?api_key=\(API.KEY)"
    static let ROUTE_POPULAR_MOVIES = "\(API.BASE_URL)/movie/popular?api_key=\(API.KEY)"
    static let ROUTE_MOVIE_DETAILS = "\(API.BASE_URL)/movie"
    static let ROUTE_SEACRH_MOVIES = "\(API.BASE_URL)/search/movie"
}
