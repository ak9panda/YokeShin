//
//  MovieModel.swift
//  YokeShin
//
//  Created by aung on 11/7/19.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation
import RealmSwift

class MovieModel {
    
    static let shared = MovieModel()
    
    private init() {}
    
    func fetchMovieByName (movieName : String, completion : @escaping ([MovieResponse]) -> Void) {
        let route = URL(string: "\(Routes.ROUTE_SEACRH_MOVIES)?api_key=\(API.KEY)&query=\(movieName.replacingOccurrences(of: " ", with: "%20") )")!
        URLSession.shared.dataTask(with: route) { (data, urlResponse, error) in
            let response : MovieListResponse? = self.responseHandler(data: data, urlResponse: urlResponse, error: error)
            if let data = response {
                completion(data.results)
            }
        }.resume()
    }
    
    func fetchMovieDetails (movieId : String, completion : @escaping ([MovieResponse]) -> Void) {
        let route = URL(string: "\(Routes.ROUTE_MOVIE_DETAILS)?api_key=\(API.KEY)")!
        URLSession.shared.dataTask(with: route) { (data, urlResponse, error) in
            
        }
    }
    
    func responseHandler<T : Decodable>(data : Data?, urlResponse : URLResponse?, error : Error?) -> T? {
        let TAG = String(describing: T.self)
        if error != nil {
            print("\(TAG): failed to fetch data : \(error!.localizedDescription)")
            return nil
        }
        
        let response = urlResponse as! HTTPURLResponse
        
        if response.statusCode == 200 {
            guard let data = data else {
                print("\(TAG): empty data")
                return nil
            }
            
            if let result = try? JSONDecoder().decode(T.self, from: data) {
                return result
            } else {
                print("\(TAG): failed to parse data")
                return nil
            }
        } else {
            print("\(TAG): Network Error - Code: \(response.statusCode)")
            return nil
        }
    }
}
