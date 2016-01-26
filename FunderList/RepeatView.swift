//
//  RepeatView.swift
//  FunderList
//
//  Created by Jay Lingelbach on 1/18/16.
//  Copyright © 2016 Jay Lingelbach. All rights reserved.
//

import UIKit

import UIKit

protocol RepeatViewDelegate {
    func remove()
    func done()
    func pickerViewDidSelect(type: RepeatType)
}


class RepeatView: UIView {
    

    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: RepeatViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    @IBAction func removeBarButtonItemPressed(sender: UIBarButtonItem) {
        delegate?.remove()
    }
    
    @IBAction func doneBarButtonItemPressed(sender: UIBarButtonItem) {
        delegate?.done()
    }
    
}

extension RepeatView: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "Every Day"
        case 1:
            return "Every Week"
        case 2:
            return "Every Month"
        default:
            return "Every Year"
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let repeatValue = RepeatType(rawValue: row)!
        delegate?.pickerViewDidSelect(repeatValue)
    }
    
}


extension RepeatView: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
}