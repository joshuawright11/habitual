use_frameworks!

target 'Ignite' do

    pod 'Timepiece'
    pod 'DZNEmptyDataSet'
    pod 'Parse'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'CVCalendar'
    pod 'Charts'
    pod 'DKChainableAnimationKit'
    pod 'JSQMessagesViewController'
    pod 'LTMorphingLabel'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'DynamicColor', '~> 2.3.0'
    pod 'FBSDKCoreKit'
    pod 'FBSDKShareKit'
    pod 'FBSDKLoginKit'
    pod 'ParseFacebookUtilsV4'
    pod 'SprintSwift'
end

post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end
pod 'SwiftAddressBook'

