//
//  TodoModel.swift
//  FunderList
//
//  Created by Jay Lingelbach on 10/13/15.
//  Copyright © 2015 Jay Lingelbach. All rights reserved.
//

import Foundation

enum RepeatType: Int {
    
    case Daily = 0
    case Weekly = 1
    case Monthly = 2
    case Yearly = 3
}

struct TodoModel {
    
    var title: String
    var favorited: Bool // refactor like below, right now the user is setting this.
    var dueDate: NSDate?
    var completed: Bool // refactor to be set as true. When it's created it shouldn't be automatically completed so the refactor would make sense
    var repeated: RepeatType?
    var reminder: NSDate?
    
}

