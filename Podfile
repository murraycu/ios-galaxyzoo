platform :ios, '5.1.1'
# Or platform :osx, '10.7'
pod 'RestKit', '~> 0.24.1'

# Testing and Search are optional components
pod 'RestKit/Testing', '~> 0.24.1'
pod 'RestKit/Search',  '~> 0.24.1'
pod 'SSKeychain'

# Added by murrayc.
# See https://github.com/CocoaPods/CocoaPods/wiki/Acknowledgements
post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'ios-galaxyzoo/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
