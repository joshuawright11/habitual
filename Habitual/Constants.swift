//
//  Constants.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

// -TODO: Needs refactoring/documentation

import Foundation

/// *****************
/// * Notifications *
/// *****************

struct Notifications {
    static let localNotificationsDisabled = "LocalNotificationsEnabled"
    static let habitDataChanged = "HabitDataChanged"
    static let reloadPulse = "ReloadPulse"
    static let dotwToggled = "DOTWToggled"
    static let accountabilityToggled = "AccountabilityToggled"
    static let reloadNetworkOnline = "ReloadNetworkOnline"
    static let reloadNetworkOffline = "ReloadNetworkOffline"
    static let reloadChat = "ReloadChat"
}

/// **********
/// * COLORS *
/// **********

struct Colors {
    // Main Colors
    static let barBackground = UIColor(hexString: "242C33")
    static let background = barBackground.lightenByPercentage(0.04)
    static let shadow = UIColor.blackColor()
    
    static let accent = UIColor(hexString: "F09819").colorWithAlphaComponent(0.7)
    static let accentSecondary = UIColor(hexString: "34AADC")
    static let textViewBackground = UIColor(hexString: "E6E6E6")
    
    // Logo Colors
    static let logoOrange = UIColor(hexString: "FF9500")
    static let logoRed = UIColor(hexString: "FF0000")
    
    // Text Colors
    static let textMain = UIColor(hexString: "FFFFFF")
    static let textSecondary = background.lightenByPercentage(0.2)
    static let textSubtitle = background.lightenByPercentage(0.45)
    
    // Rainbow
    static let purple = UIColor(hexString: "C644FC");
    static let blue = UIColor(hexString: "007AFF");
    static let green = UIColor(hexString: "17EB00");
    static let yellow = UIColor(hexString: "E5FF00");
    static let orange = UIColor(hexString: "FF8300");
    static let red = UIColor(hexString: "FF2D55");
    
    static let rainbow = [purple, blue, green, yellow, orange, red]
}

/// **********
/// *  FONTS *
/// **********

struct Fonts {

    // Main Fonts
    static let mainTitle = UIFont.systemFontOfSize(32.0, weight: UIFontWeightUltraLight)
    static let body = UIFont.systemFontOfSize(16.0, weight: UIFontWeightRegular)
    static let secondary = UIFont.systemFontOfSize(12.0, weight: UIFontWeightUltraLight)
    static let secondaryBold = UIFont.systemFontOfSize(12.0, weight: UIFontWeightHeavy)
    static let secondaryLight = UIFont.systemFontOfSize(12.0, weight: UIFontWeightRegular)
    static let calendar = UIFont.systemFontOfSize(18.0, weight: UIFontWeightLight)
    static let initials = UIFont.systemFontOfSize(24.0, weight: UIFontWeightLight)
    
    // Navigation Bar
    static let navTitle = UIFont.systemFontOfSize(20.0, weight: UIFontWeightSemibold)
    static let navButtons = UIFont.systemFontOfSize(17.0, weight: UIFontWeightRegular)
    
    // Tab Bar
    static let tabBarTitle = UIFont.systemFontOfSize(10.0, weight: UIFontWeightMedium)
    
    // Table Views
    static let cellTitle = UIFont.systemFontOfSize(20.0, weight: UIFontWeightRegular)
    static let cellSubtitle = UIFont.systemFontOfSize(14.0, weight: UIFontWeightLight)
    static let cellSubtitleBold = UIFont.systemFontOfSize(14.0, weight: UIFontWeightSemibold)
    static let sectionHeader = UIFont.systemFontOfSize(18.0, weight: UIFontWeightLight)
    static let sectionHeaderBold = UIFont.systemFontOfSize(14.0, weight: UIFontWeightLight)
    static let message = UIFont.systemFontOfSize(16.0, weight: UIFontWeightRegular)
    static let monthLabel = UIFont.systemFontOfSize(20.0, weight: UIFontWeightLight)

}

/// **********
/// *  ICONS *
/// **********

struct Icons {
    static let iconList = [
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
}

/// **********
/// * FLOATS *
/// **********

struct Floats {
    static let colorAlpha: CGFloat = 0.3
}

