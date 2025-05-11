# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'DFGithub' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DFGithub
  ##############################################
  ###               Business                 ###
  ##############################################

  
  ##############################################
  ###              Foundation                ###
  ##############################################
  # Extesions
  pod 'SwifterSwift'
  
  # Rx & Rx Extensions
  pod 'RxDataSources', '~> 5.0'
  pod 'RxSwiftExt', '~> 6.0'
  pod 'NSObject+Rx', '~> 5.0'
  pod 'RxViewController', '~> 2.0'
  pod 'RxGesture', '~> 4.0'
  pod 'RxOptional', '~> 5.0'
  pod 'RxTheme', '~> 6.0'
  
  # Networking
  pod 'Kingfisher', '~> 7.12.0'
  pod 'Moya/RxSwift', '~> 15.0'
  
  # Keychain
  pod 'KeychainAccess', '~> 4.0'  # https://github.com/kishikawakatsumi/KeychainAccess
  
  # Resources
  pod 'R.swift', '~> 7.0'
  
  # JSON Mapping
  pod 'Moya-ObjectMapper/RxSwift', :git => 'https://github.com/p-rob/Moya-ObjectMapper.git', :branch => 'master'
  pod 'ObjectMapper', :git => 'https://github.com/tristanhimmelman/ObjectMapper.git', :branch => 'master'
  
  # Keyboard
  pod 'IQKeyboardManagerSwift', '~> 8.0'
  
  # UIKit
  pod 'SVProgressHUD', '~> 2.0'
  pod 'DZNEmptyDataSet'
  pod "MBProgressHUD"
  pod "KafkaRefresh"
  pod 'BonMot', '~> 6.0'
  pod 'Toast-Swift', '~> 5.0'
  pod 'HMSegmentedControl', '~> 1.0'
  pod 'DropDown', '~> 2.0'
  pod 'SwiftEntryKit', :git => 'https://github.com/davidfuzju/SwiftEntryKit.git', :branch => 'master'
  
  # Auto Layout
  pod 'SnapKit', '~> 5.0'
  
  #
  pod 'SwiftDate', '~> 7.0'
  
  pod 'Localize-Swift', '~> 3.2'
  
  # Debug
  pod 'LookinServer', :subspecs => ['Swift'], :configurations => ['Debug']
  
  target 'DFGithubTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DFGithubUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  
  # 解决xcode 15 报错 xcode SDK does not contain ‘libarclite‘
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  
  # Enable tracing resources
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
      end
    end
  end
  
end
