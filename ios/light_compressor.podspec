#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint light_compressor.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'light_compressor'
  s.version          = '1.0.0'
  s.summary          = 'Light Compressor Library'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/AbedElazizShe'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'elaziz.shehadeh@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
