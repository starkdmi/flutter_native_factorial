#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint factorial.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'factorial'
  s.version          = '0.0.1'
  s.summary          = 'The Factorial calculation using native platform code.'
  s.description      = <<-DESC
A Darwin implementation of the factorial plugin.
                       DESC
  s.homepage         = 'https://github.com/starkdmi/flutter_native_factorial'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Dmitry Starkov' => 'starkdev@icloud.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  # Flutter dependency
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.14'
  # Any other dependencies required for the plugin 
  # s.dependency 'MediaToolSwift'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.8'
end