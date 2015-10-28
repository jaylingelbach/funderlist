//
//  AddTodoTableViewCell.swift
//  FunderList
//
//  Created by Jay Lingelbach on 10/9/15.
//  Copyright © 2015 Jay Lingelbach. All rights reserved.
//

import UIKit

class AddTodoTableViewCell: UITableViewCell {

    @IBOutlet weak var addTodoTextField: UITextField!
    
    @IBOutlet weak var favoriteButton: UIButton!

    var favorited: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func favoriteButtonTapped(sender: UIButton) {
        
        if addTodoTextField.isFirstResponder() {
            
            favorited = !favorited
            
            if favorited {
                favoriteButton.backgroundColor = UIColor.blueColor()
            }
        
            else {
                favoriteButton.backgroundColor = UIColor.orangeColor()
            }
            
        }

    }
    
}
