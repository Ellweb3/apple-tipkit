Pod::Spec.new do |s|
  s.name             = 'apple_tipkit'
  s.version          = '0.1.0'
  s.summary          = 'Flutter wrapper over Apple TipKit (iOS 17+).'
  s.description      = <<-DESC
  Plugin provides basic TipKit methods: initializeTips, displayTip, markTipAsShown, resetAllTips.
  DESC
  s.homepage         = 'https://pub.dev/packages/apple_tipkit'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.platform         = :ios, '17.0'
  s.swift_version    = '5.9'
  s.ios.deployment_target = '17.0'
  s.frameworks       = 'UIKit', 'SwiftUI', 'TipKit'
  s.dependency 'Flutter'

  # Simulator and device support (xcframework not required, using system TipKit)
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => ''
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '' }
end


