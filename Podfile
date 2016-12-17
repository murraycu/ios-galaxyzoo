target "ios-galaxyzoo" do
  platform :ios, '8.0.0'
  # Or platform :osx, '10.7'
  # pod 'RestKit', '~> 0.27.0'
  # See https://github.com/RestKit/RestKit/pull/2449#issuecomment-255368250
  pod 'RestKit', :git => 'https://github.com/RestKit/RestKit.git', :commit => '13d98d5a6a5e06656ad040013dcae149b7cf8b99'

  # Testing and Search are optional components
  #pod 'RestKit/Testing', '~> 0.27.0'
  pod 'RestKit/Testing', :git => 'https://github.com/RestKit/RestKit.git', :commit => '13d98d5a6a5e06656ad040013dcae149b7cf8b99'
  #pod 'RestKit/Search',  '~> 0.27.0'
  pod 'RestKit/Search', :git => 'https://github.com/RestKit/RestKit.git', :commit => '13d98d5a6a5e06656ad040013dcae149b7cf8b99'
  pod 'SSKeychain'
  pod 'AFNetworking', '~> 3.0'

  # Added by murrayc.
  # See https://github.com/CocoaPods/CocoaPods/wiki/Acknowledgements
  post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-ios-galaxyzoo/Pods-ios-galaxyzoo-acknowledgements.plist', 'ios-galaxyzoo/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  end
end
