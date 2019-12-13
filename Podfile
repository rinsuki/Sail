# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
source 'https://cdn.cocoapods.org/'

use_frameworks!

target 'SailCore' do
  pod 'Alamofire', '~> 4.9.1'
  pod 'GRDB.swift'
  pod 'KeychainAccess'
  pod '※ikemen'
  pod 'HydraAsync'
end

target 'Sail' do
  # Comment the next line if you don't want to use dynamic frameworks

  # Pods for Sail
  pod 'Nuke', '~> 8.3'
  pod 'Nuke-WebP-Plugin'
  
  pod 'Mew', :git => 'https://github.com/rinsuki/Mew.git', :branch => 'fix/podspec'
  pod 'Eureka', '~> 5.1.0'
  pod 'EurekaFormBuilder', '~> 0.2.0'
  
  pod 'SnapKit', '~> 5.0.1'
  
  target 'SailTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SailUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
