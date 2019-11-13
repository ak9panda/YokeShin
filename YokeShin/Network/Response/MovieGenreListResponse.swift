//
//  MovieGenreListResponse.swift
//  YokeShin
//
//  Created by aung on 11/5/19.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation
import RealmSwift

struct MovirGenreListResponse : Codable {
    let genres : [MovieGenreResponse]
}
