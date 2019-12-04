//
//  GenreListTableViewCell.swift
//  YokeShin
//
//  Created by admin on 26/11/2019.
//  Copyright © 2019 aung. All rights reserved.
//

import UIKit

class GenreListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblGenreName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var identifier : String {
        return String(describing: self)
    }
}
