# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GYMDIARY' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GYMDIARY

  pod 'Charts', :git => ‘https://github.com/danielgindi/Charts.git’, :branch => ‘master’
  pod 'RealmSwift', '~> 2.7.0’

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = ‘3.1’
      end
    end
  end

  target 'GYMDIARYTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GYMDIARYUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
