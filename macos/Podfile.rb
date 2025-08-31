# Podfile for PlaToN Sport (Flutter)
platform :ios, '12.0'

# استخدم سكربت Flutter الرسمي
flutter_root = File.expand_path('..', File.dirname(__FILE__))
load File.join(flutter_root, 'Flutter', 'flutter_export_environment.rb')
load File.join(ENV['FLUTTER_ROOT'], 'packages', 'flutter_tools', 'bin', 'podhelper.rb')

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks! :linkage => :static
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # دعم Swift 5 و iOS 12+
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
