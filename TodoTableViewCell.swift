//
//  TodoTableViewCell.swift
//  FunderList
//
//  Created by Jay Lingelbach on 10/9/15.
//  Copyright © 2015 Jay Lingelbach. All rights reserved.
//

import UIKit

protocol TodoTableViewDelegate {
    func completeTodo(indexPath: NSIndexPath)
    func favoriteTodo(indexPath: NSIndexPath)
}

class TodoTableViewCell: UITableViewCell {

    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var indexPath : NSIndexPath!
    var delegate : TodoTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func completeButtonTapped(sender: UIButton) {
        delegate?.completeTodo(indexPath)
    }
    
    @IBAction func favoriteButtonTapped(sender: UIButton) {
        delegate?.favoriteTodo(indexPath)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            dateLabel.hidden = true
            completeButton.hidden = true
            favoriteButton.hidden = true
            
        }
        
        else {
            dateLabel.hidden = false
            completeButton.hidden = false
            favoriteButton.hidden = false
        }
    }
    
}
