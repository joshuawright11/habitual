//
//  DatePickerCell.swift
//  Ignite
//
//  Created by Josh Wright on 1/20/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell {
    
    static let height = 225
    
    static let reuseID = "DatePickerCell"
    
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.setValue(Colors.textMain, forKey: "textColor")
        }
    }
}
