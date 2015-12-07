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
    static let localNotificationsDisabled = "LocalNotificationsEnabled"
}

let kNotificationIdentifierHabitAddedOrDeleted = "HabitAddedOrDeleted"
let kNotificationIdentifierHabitDataChanged = "HabitDataChanged"

let kNotificationIdentifierToggleDOTW = "ToggleDotw"
let kNotificationIdentifierToggleAccountability = "ToggleAccountability"

let kNotificationIdentifierReloadConnections = "ReloadNetwork"
let kNotificationChatReceived = "ReloadChat"

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
let kColorTextSecondary = kColorBackground.lightenByPercentage(0.2)
let kColorTextSubtitle = kColorBackground.lightenByPercentage(0.45)

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
let kFontSecondary = UIFont.systemFontOfSize(12.0, weight: UIFontWeightUltraLight)
let kFontSecondaryBold = UIFont.systemFontOfSize(12.0, weight: UIFontWeightHeavy)
let kFontSecondaryLight = UIFont.systemFontOfSize(12.0, weight: UIFontWeightRegular)
let kFontCalendar = UIFont.systemFontOfSize(18.0, weight: UIFontWeightLight)
let kFontInitials = UIFont.systemFontOfSize(24.0, weight: UIFontWeightLight)

// Navigation Bar
let kFontNavTitle = UIFont.systemFontOfSize(20.0, weight: UIFontWeightSemibold)
let kFontNavButtons = UIFont.systemFontOfSize(17.0, weight: UIFontWeightRegular)

// Tab Bar
let iFontTabBarTitle = UIFont.systemFontOfSize(10.0, weight: UIFontWeightMedium)

// Table Views
let kFontCellTitle = UIFont.systemFontOfSize(20.0, weight: UIFontWeightRegular)
let kFontCellSubtitle = UIFont.systemFontOfSize(14.0, weight: UIFontWeightLight)
let kFontSectionHeader = UIFont.systemFontOfSize(18.0, weight: UIFontWeightLight)
let kFontSectionHeaderBold = UIFont.systemFontOfSize(18.0, weight: UIFontWeightMedium)
let kFontMessage = UIFont.systemFontOfSize(16.0, weight: UIFontWeightRegular)
let kFontMonthLabel = UIFont.systemFontOfSize(20.0, weight: UIFontWeightLight)

/// **********
/// *  ICONS *
/// **********

struct Icons {
    
}

let iIconList = [
    "aim_target",
    "alarm_square",
    "arrows_axis_angle",
    "bullet_list",
    "camera",
    "cheeseburger",
    "compass",
    "email_open",
    "heart_rate",
    "iphone_delete",
    "ledger",
    "light_bulb_on",
    "loop",
    "male_female_symbol",
    "map_route",
    "moon",
    "mortar_board",
    "palette",
    "paw_print",
    "pencil",
    "piggy_bank_coin",
    "podium_mic",
    "rocket",
    "running",
    "single_bed",
    "sprint_cycling",
    "ui_code",
    "users_two",
    "weight_lifting",
    "yoga"]

/// **********
/// * FLOATS *
/// **********

struct Floats {
    static let colorAlpha: CGFloat = 0.3
}

