platform :osx, '10.10'
use_frameworks!
inhibit_all_warnings!

## Since Cocoapods does not work with console app.
target 'SwiftyJSONAcceleratorTests' do
  pod 'Nimble'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts target.name
  end
end
