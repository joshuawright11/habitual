//
//  Constants.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation


/// ************
/// * Keychain *
/// ************

let kKeychainUserAccount = "Habitual"

/// *****************
/// * Notifications *
/// *****************

struct Notifications {
    
}

let kNotificationIdentifierHabitAddedOrDeleted = "HabitAddedOrDeleted"
let kNotificationIdentifierHabitDataChanged = "HabitDataChanged"

let kNotificationIdentifierToggleDOTW = "ToggleDotw"
let kNotificationIdentifierToggleAccountability = "ToggleAccountability"

let kNotificationIdentifierReloadConnections = "ReloadConnections"

let kNotificationChatReceived = "ChatReceived"

/// **********
/// * COLORS *
/// **********

struct Colors {
    
}

// Main Colors
let kColorBarBackground = UIColor(hexString: "242C33")
let kColorBackground = kColorBarBackground.lightenByPercentage(0.04)
let kColorShadow = UIColor.blackColor()

let kColorAccent = UIColor(hexString: "F09819").colorWithAlphaComponent(0.7)
let kColorAccentSecondary = UIColor(hexString: "34AADC")
let kColorTextViewBackground = UIColor(hexString: "E6E6E6")

// Logo Colors
let kColorLogoOrange = UIColor(hexString: "FF9500")
let kColorLogoRed = UIColor(hexString: "FF0000")

// Text Colors
let kColorTextMain = UIColor(hexString: "FFFFFF")
let kColorTextSecondary = UIColor(hexString: "717B80")

// Rainbow
let kColorPurple = UIColor(hexString: "C644FC");
let kColorBlue = UIColor(hexString: "007AFF");
let kColorGreen = UIColor(hexString: "17EB00");
let kColorYellow = UIColor(hexString: "E5FF00");
let kColorOrange = UIColor(hexString: "FF8300");
let kColorRed = UIColor(hexString: "FF2D55");
let kColorTeal = UIColor(hexString: "00DFFC");

let kColorArray = [kColorPurple, kColorBlue, kColorGreen, kColorYellow, kColorOrange, kColorRed, kColorTeal]

/// **********
/// *  FONTS *
/// **********

struct Fonts {
    
}

// Font Name
let kFontName = "SanFranciscoDisplay"

// Main Fonts
let kFontMainTitle = UIFont.systemFontOfSize(32.0, weight: UIFontWeightUltraLight)
let kFontBody = UIFont.systemFontOfSize(16.0, weight: UIFontWeightRegular)
let kFontSecondary = UIFont.systemFontOfSize(12.0, weight: UIFontWeightBold)
let kFontSecondaryLight = UIFont.systemFontOfSize(12.0, weight: UIFontWeightRegular)
let kFontCalendar = UIFont.systemFontOfSize(18.0, weight: UIFontWeightLight)
let kFontInitials = UIFont.systemFontOfSize(24.0, weight: UIFontWeightLight)

// Navigation Bar
let kFontNavTitle = UIFont.systemFontOfSize(22.0, weight: UIFontWeightLight)
let kFontNavButtons = UIFont.systemFontOfSize(17.0, weight: UIFontWeightRegular)

// Tab Bar
let iFontTabBarTitle = UIFont.systemFontOfSize(10.0, weight: UIFontWeightMedium)

// Table Views
let kFontCellTitle = UIFont.systemFontOfSize(20.0, weight: UIFontWeightRegular)
let kFontCellSubtitle = UIFont.systemFontOfSize(14.0, weight: UIFontWeightLight)
let kFontSectionHeader = UIFont.systemFontOfSize(18.0, weight: UIFontWeightRegular)
let kFontSectionHeaderBold = UIFont.systemFontOfSize(18.0, weight: UIFontWeightMedium)
let kFontMessage = UIFont.systemFontOfSize(16.0, weight: UIFontWeightRegular)

/// **********
/// *  ICONS *
/// **********

struct Icons {
    
}

let iIconList = [
    "flash",
    "headphone",
    "heart",
    "ios-at-outline",
    "ios-basketball-outline",
    "ios-body-outline",
    "ios-bookmarks-outline",
    "ios-box-outline",
    "ios-cloudy-night-outline",
    "ios-flask-outline",
    "ios-flower-outline",
    "ios-lightbulb-outline",
    "ios-list-outline",
    "ios-location-outline",
    "ios-paw-outline",
    "ios-people-outline",
    "ios-pulse",
    "ios-stopwatch-outline",
    "ios-sunny-outline",
    "ios-telephone-outline",
    "laptop"]

/// **********
/// * FLOATS *
/// **********

struct Floats {
    static let colorAlpha: CGFloat = 0.3
}

