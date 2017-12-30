# Uncomment this line to define a global platform for your project
# platform :ios, ’10.0’

target 'IntelliPlug Assistant' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for IntelliPlug Assistant
  pod 'RealmSwift', :git => 'https://github.com/realm/realm-cocoa.git', :submodules => true 
  pod 'Realm', :git => 'https://github.com/realm/realm-cocoa.git', :submodules => true
  pod 'Alamofire', '~> 4.0'
  pod 'Gloss', '~> 0.7'
  pod "PromiseKit", "~> 4.0"
  pod 'IBAnimatable', '~> 3.0'
  # pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift3'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

  target 'IntelliPlug AssistantTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'IntelliPlug AssistantUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
