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

let kNotificationIdentifierHabitAddedOrDeleted = "HabitAddedOrDeleted"
let kNotificationIdentifierHabitDataChanged = "HabitDataChanged"

let kNotificationIdentifierToggleDOTW = "ToggleDotw"
let kNotificationIdentifierToggleAccountability = "ToggleAccountability"

let kNotificationIdentifierReloadConnections = "ReloadConnections"

let kNotificationChatReceived = "ChatReceived"

/// **********
/// * COLORS *
/// **********

// Main Colors
let kColorBackground = UIColor(hexString: "242C33");
let kColorAccent = UIColor(hexString: "F09819");
let kColorAccentSecondary = UIColor(hexString: "34AADC");
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

// Font Name
let kFontName = "Avenir"

// Main Fonts
let kFontMainTitle = UIFont(name: kFontName+"-Light", size: 32.0)!
let kFontBody = UIFont(name: kFontName, size: 16.0)!
let kFontSecondary = UIFont(name: kFontName+"-Black", size: 12.0)!
let kFontSecondaryLight = UIFont(name: kFontName, size: 12.0)!
let kFontCalendar = UIFont(name: kFontName+"-Heavy", size: 18.0)!
let kFontInitials = UIFont(name: kFontName, size: 24.0)!

// Navigation Bar
let kFontNavTitle = UIFont(name: kFontName+"-Heavy", size: 20.0)!
let kFontNavButtons = UIFont(name: kFontName, size: 17.0)!

// Tab Bar
let iFontTabBarTitle = UIFont(name: kFontName+"-Heavy", size: 10.0)!

// Table Views
let kFontCellTitle = UIFont(name: kFontName+"-Light", size: 20.0)!
let kFontCellSubtitle = UIFont(name: kFontName+"-Light", size: 15.0)!
let kFontSectionHeader = UIFont(name: kFontName+"-Heavy", size: 16.0)!
let kFontMessage = UIFont(name: kFontName, size: 16.0)!

/// **********
/// *  ICONS *
/// **********

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

