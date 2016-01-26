//
//  DatePickerView.swift
//  FunderList
//
//  Created by Jay Lingelbach on 1/11/16.
//  Copyright © 2016 Jay Lingelbach. All rights reserved.
//

import UIKit
import Foundation

// so we can talk to the TodoViewController
protocol DatePickerViewDelegate {
    func removePressed()
    func donePressed()
    func datePickerValueChanged(date: NSDate)

}

class DatePickerView: UIView {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: DatePickerViewDelegate?
    
    @IBAction func removeBarButtonItemPressed(sender: UIBarButtonItem) {
        //function called on delegate so TodoViewController knows to listen to the DatePickerView
        delegate?.removePressed()
    }
    
    @IBAction func doneBarButtonItemPressed(sender: UIBarButtonItem) {
        //function called on delegate so TodoViewController knows to listen to the DatePickerView
        delegate?.donePressed()
    }
    
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
    
        delegate?.datePickerValueChanged(sender.date)
    }
    

}
