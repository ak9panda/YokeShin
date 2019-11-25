//
//  MovieListCollectionViewCell.swift
//  YokeShin
//
//  Created by admin on 25/11/2019.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class MovieListCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var imageMoviePoster: UIImageView!
    
    var data : MovieVO? {
        didSet {
            if let data = data {
                imageMoviePoster.sd_setImage(with: URL(string: "\(API.BASE_IMG_URL)\(data.poster_path ?? "")"), placeholderImage: #imageLiteral(resourceName: "ic_movie"), options:  SDWebImageOptions.progressiveLoad, completed: nil)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static var identifier : String {
        return String(describing: self)
    }
}
