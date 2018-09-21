Pod::Spec.new do |spec|
  spec.name = 'PinPayments'
  spec.version = '0.0.1'
  spec.license = 'BSD'
  spec.summary = 'Pin Payments iOS SDK'
  spec.homepage = 'https://github.com/KrugerHeavyIndustries/pinpayments-ios-sdk'
  spec.authors = { 'Chris Kruger': 'ios-sdk@krugerheavyindustries.com' }
  spec.source = { git: 'https://github.com/KrugerHeavyIndustries/pinpayments-ios-sdk.git', tag: '0.0.1' }
  spec.requires_arc = true

  spec.source_files = "PinPayments/*.{h,m}"

  spec.platform = :ios, :osx, :tvos, :watchos
  spec.ios.deployment_target = '7.0'
  spec.osx.deployment_target = '10.9'
  spec.watchos.deployment_target = '2.0'
  spec.tvos.deployment_target = '9.0'

  spec.dependency 'AFNetworking', '~> 3.0'
end
