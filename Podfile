platform :osx, '10.10'
use_frameworks!
inhibit_all_warnings!


target 'SwiftyJSONAccelerator' do
  pod 'SwiftyJSON', '~> 2.3'

  target 'SwiftyJSONAcceleratorTests’ do
     pod 'Nimble', '~> 4.0.0'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts target.name
  end
end