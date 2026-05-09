#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_torch.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_torch'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for controlling torch/flashlight functionality.'
  s.description      = <<-DESC
A comprehensive Flutter plugin for controlling the torch/flashlight on mobile devices through native platform integration.
                       DESC
  s.homepage         = 'https://github.com/yourusername/native_torch'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
