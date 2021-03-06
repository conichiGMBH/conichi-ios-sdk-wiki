Pod::Spec.new do |s|
  s.name         = 'CNISDKSumUpKit'
  s.version      = '4.1.37'
  s.summary      = "SumUp kit extends the CNISDKCoreKit with payment functionality through SumUp provider."

  s.description  = <<-DESC
                    Conichi SDK simplifies the use of Apple’s iBeacon technology with conichi's hardware. In only few steps, you will be able to communicate with our beacons and receive actions confirmation by a conichi venue. With paymentKit it also enables the mobile payment.
                   DESC

  s.license      = { :type => "Conichi License", :file => "LICENSE" }
  s.homepage     = 'https://github.com/conichiGMBH'
  s.author       = { 'conichiGMBH' => 'support@conichi.com' }

  s.source                = { :git => "https://github.com/conichiGMBH/conichi-ios-sdk.git", :tag => s.version.to_s}
  s.platform              = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.source_files          = 'Frameworks/CNISDKSumUpKit.framework/Headers/*.h'
  s.requires_arc          = true
  s.module_name           = 'CNISDKSumUpKit'
  s.public_header_files   = 'Frameworks/CNISDKSumUpKit.framework/Headers/*.h'
  s.vendored_frameworks   = 'Frameworks/CNISDKSumUpKit.framework'
  s.preserve_paths        = 'Frameworks/CNISDKSumUpKit.framework'
  s.xcconfig              = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited)' }

  s.dependency 'CNISDKCoreKit', "#{s.version}"
  s.dependency 'CNISDKPaymentKit', "#{s.version}"
end
