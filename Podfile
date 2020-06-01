# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

def common
  # Pods for mask-rxtest
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxSwiftExt', '~> 5'
  pod 'Moya/RxSwift', '~> 14.0'
  pod 'RxDataSources', '~> 4.0'
end

def test
  # Pods for testing
    pod 'Quick'
    pod 'RxNimble/RxTest'
end

target 'RxMvvmChuLe' do
  common
  target 'RxMvvmChuLeTests' do
    inherit! :search_paths
    test
  end

end
