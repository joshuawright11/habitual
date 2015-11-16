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
let kNotificationIdentifierUserLoggedIn = "UserLoggedIn"

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
let kColorTextSecondary = UIColor(hexString: "A3B0B7")

// Rainbow
let kColorPurple = UIColor(hexString: "C644FC");
let kColorBlue = UIColor(hexString: "007AFF");
let kColorGreen = UIColor(hexString: "0BD318");
let kColorYellow = UIColor(hexString: "FFF200");
let kColorOrange = UIColor(hexString: "FF9500");
let kColorRed = UIColor(hexString: "FF0F03");
let kColorTeal = UIColor(hexString: "10C0DF");

let kColorArray = [kColorPurple, kColorBlue, kColorGreen, kColorYellow, kColorOrange, kColorRed, kColorTeal]

/// **********
/// *  FONTS *
/// **********

// Font Name
let kFontName = "Avenir"

// Main Fonts
let kFontMainTitle = UIFont(name: kFontName+"-Light", size: 32.0)!
let kFontBody = UIFont(name: kFontName, size: 16.0)!
let kFontSecondary = UIFont(name: kFontName+"-Heavy", size: 12.0)!
let kFontCalendar = UIFont(name: kFontName+"-Heavy", size: 18.0)!

// Navigation Bar
let kFontNavTitle = UIFont(name: kFontName+"-Heavy", size: 20.0)!

// Tab Bar
let iFontTabBarTitle = UIFont(name: kFontName+"-Heavy", size: 10.0)!

// Table Views
let kFontCellTitle = UIFont(name: kFontName+"-Light", size: 20.0)!
let kFontCellSubtitle = UIFont(name: kFontName+"-Light", size: 15.0)!
let kFontSectionHeader = UIFont(name: kFontName+"-Heavy", size: 16.0)!



