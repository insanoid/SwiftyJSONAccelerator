WORKSPACE = SwiftyJSONAccelerator.xcworkspace
PROJECT = SwiftyJSONAccelerator.xcodeproj
SCHEME = "SwiftyJSONAccelerator"

synxify:
	bundle exec synx $(PROJECT)

build:
	xcodebuild ONLY_ACTIVE_ARCH=NO -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration Debug clean build | tee xcodebuild.log | xcpretty

citest:
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) test | tee xcodebuild.log | xcpretty -s

test:
	rm -rf build
	xcodebuild ONLY_ACTIVE_ARCH=NO -workspace $(WORKSPACE) -scheme $(SCHEME) test | tee xcodebuild.log | xcpretty -s
	slather
	rm xcodebuild.log
