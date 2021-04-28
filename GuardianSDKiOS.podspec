#
#  Be sure to run `pod spec lint GuardianSDKiOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "GuardianSDKiOS"
  spec.version      = "1.1.28"
  spec.summary      = "A summary description of GuardianSDKiOS."

  spec.description  = "A Description of GuardianSDKiOS CocoaPads Framework"

  spec.homepage     = "http://EXAMPLE/GuardianSDKiOS"
  spec.license      = "MIT"

  spec.author             = { "jhkim" => "jhkim@fnsvalue.co.kr" }

  spec.platform     = :ios, "12.0"

  spec.source       = { :git => "https://github.com/fnsvalue-git/GuardianSDKiOS.git", :tag => "#{spec.version}" }

  spec.source_files  = "GuardianSDKiOS", "GuardianSDKiOS/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"

  spec.dependency 'Alamofire', '~> 4.4'
  spec.dependency 'CryptoSwift'
  spec.dependency 'SwiftyJSON'
  spec.dependency 'StompClientLib'
  spec.dependency 'DeviceKit'
  spec.swift_version = '4.2'

end
