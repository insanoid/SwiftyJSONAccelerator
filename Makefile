WORKSPACE = SwiftyJSONAccelerator.xcworkspace
PROJECT = SwiftyJSONAccelerator.xcodeproj
TEMPORARY_FOLDER?=/tmp/SwiftyJSONAccelerator.dst/
BUILD_TOOL?=xcodebuild
PIPE_FAIL = set -o pipefail &&
XCPRETTY = | xcpretty -s

APP_SCHEME = "SwiftyJSONAccelerator"
APP_NAME = SwiftyJSONAccelerator.app
APP_INSTALLATION_PATH = /Applications/

XCODEFLAGS_APP=-workspace $(WORKSPACE) \
	-scheme $(APP_SCHEME) \
	CODE_SIGN_IDENTITY="" \
	CODE_SIGNING_REQUIRED=NO \
	CONFIGURATION_BUILD_DIR=$(TEMPORARY_FOLDER)

# Format the folder structure.
synxify:
	synx -p \
	-e "SwiftyJSONAccelerator/UI/External-Libraries" \
	$(PROJECT)

# Format the folder structure.
lint:
	swiftlint autocorrect
	swiftlint
	swiftformat .

# Clean the projects.
clean:
	@rm -rf "$(TEMPORARY_FOLDER)"
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Debug clean $(XCPRETTY)
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Release clean $(XCPRETTY)
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Test clean $(XCPRETTY)

# Run test for the app.
test:
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Test | tee xcodebuild.log $(XCPRETTY)
	@slather coverage --show --html --scheme $(APP_SCHEME) $(PROJECT)
	@rm xcodebuild.log
