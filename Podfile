# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

workspace 'PinPayments.xcworkspace'

target 'PinPaymentsStartProject' do
  project 'StarterProject/PinPaymentsStartProject.xcodeproj'
end

target 'PinPayments' do
  project 'PinPayments.xcodeproj'
  pod 'AFNetworking', '~> 3.0'

  target 'PinPaymentsTests' do
    inherit! :search_paths
    pod 'OHHTTPStubs'
  end
end
