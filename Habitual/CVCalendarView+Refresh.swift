//
//  CVCalendarView+Refresh.swift
//  Ignite
//
//  Created by Josh Wright on 3/23/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation
import CVCalendar

extension CVCalendarView {
    public func refresh() {
        for weekView in contentController.presentedMonthView.weekViews {
            for dayView in weekView.dayViews {
                for view in dayView.subviews {
                    if view is CVAuxiliaryView {
                        view.removeFromSuperview()
                    }
                }
                dayView.preliminarySetup()
            }
        }
    }
}
