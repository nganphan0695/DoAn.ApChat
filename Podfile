# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Takenoko' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Takenoko
  pod 'MBProgressHUD', '~> 1.2.0'
  pod 'Kingfisher', '~> 7.0'
  pod 'FirebaseAuth'
  pod 'FirebaseDatabase'
  pod 'FirebaseStorage'
  pod 'FirebaseFirestore'
  pod 'MessageKit'
  pod 'IQKeyboardManagerSwift'
  pod 'SwiftHEXColors'
 
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
