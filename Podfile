link_with 'Ignite'
use_frameworks!

pod 'SwiftyJSON'
pod 'Alamofire'
pod 'Locksmith'
pod 'Timepiece'
pod 'DZNEmptyDataSet'
pod 'Parse'
pod 'Fabric'
pod 'Crashlytics'
pod 'CVCalendar'
pod 'Charts'
pod 'DKChainableAnimationKit'
pod 'JSQMessagesViewController'
pod 'TextFieldEffects'
pod 'LTMorphingLabel'
pod 'SCLAlertView'
pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
pod 'DynamicColor', '~> 2.3.0'
pod 'FBSDKCoreKit'
pod 'FBSDKShareKit'
pod 'FBSDKLoginKit'
pod 'ParseFacebookUtilsV4'

post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end
pod 'SwiftAddressBook'

