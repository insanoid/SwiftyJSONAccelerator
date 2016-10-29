platform :osx, '10.10'
use_frameworks!
inhibit_all_warnings!


target 'SwiftyJSONAccelerator' do
  pod 'SwiftyJSON'
end

target 'SwiftyJSONAcceleratorTests' do
  pod 'SwiftyJSON'
  pod 'Nimble'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts target.name
  end
end
