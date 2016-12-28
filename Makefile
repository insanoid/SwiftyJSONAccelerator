WORKSPACE = SwiftyJSONAccelerator.xcworkspace
PROJECT = SwiftyJSONAccelerator.xcodeproj
TEMPORARY_FOLDER?=/tmp/SwiftyJSONAccelerator.dst/
BUILD_TOOL?=xcodebuild

APP_SCHEME = "SwiftyJSONAccelerator"
CLI_SCHEME = "SJAccelerator - CLI"
APP_NAME = SwiftyJSONAccelerator.app
CLI_NAME = swiftyjsonaccelerator
APP_INSTALLATION_PATH = /Applications/
CLI_INSTALLATION_PATH = /usr/local/bin/

XCODEFLAGS_APP=-workspace $(WORKSPACE) \
	-scheme $(APP_SCHEME) \
	DSTROOT=$(TEMPORARY_FOLDER) \
	CODE_SIGN_IDENTITY="" \
	CODE_SIGNING_REQUIRED=NO \
	CONFIGURATION_BUILD_DIR=$(TEMPORARY_FOLDER)

XCODEFLAGS_CLI=-workspace $(WORKSPACE) \
	-scheme $(CLI_SCHEME) \
	DSTROOT=$(TEMPORARY_FOLDER) \
	CODE_SIGN_IDENTITY="" \
	CODE_SIGNING_REQUIRED=NO \
	CONFIGURATION_BUILD_DIR=$(TEMPORARY_FOLDER)

# Format the folder structure.
synxify:
	@bundle exec synx -p \
	-e "Core/External-Libraries" \
	-e "SwiftyJSONAccelerator-CLI/External-Libraries" \
	$(PROJECT)

# Clean the projects.
clean:
	@rm -rf "$(TEMPORARY_FOLDER)"
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Debug clean | xcpretty -s
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Release clean | xcpretty -s
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Test clean | xcpretty -s
	@$(BUILD_TOOL) $(XCODEFLAGS_CLI) -configuration Debug clean | xcpretty -s
	@$(BUILD_TOOL) $(XCODEFLAGS_CLI) -configuration Release clean | xcpretty -s
	@$(BUILD_TOOL) $(XCODEFLAGS_CLI) -configuration Test clean | xcpretty -s

# Run test for the app.
test:
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Test | tee xcodebuild.log | xcpretty -s
	@slather coverage --show --html --scheme $(APP_SCHEME) $(PROJECT)
	@rm xcodebuild.log

install: bootstrap uninstall
# Application
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Release | xcpretty -s
	@cp -r $(TEMPORARY_FOLDER)$(APP_NAME) $(APP_INSTALLATION_PATH)$(APP_NAME)
# CLI
	@$(BUILD_TOOL) $(XCODEFLAGS_CLI) -configuration Release | xcpretty -s
	@cp $(TEMPORARY_FOLDER)$(CLI_NAME) $(CLI_INSTALLATION_PATH)
	@echo " ✓ SwiftyJSONAccelerator app and CLI successfully installed!! 🍻 "
	@echo " ✓ Use the app from Applications or ./"$(CLI_NAME)

uninstall:
	@rm -rf $(APP_INSTALLATION_PATH)$(APP_NAME)
	@rm -f $(CLI_INSTALLATION_PATH)$(CLI_NAME)
	
bootstrap: dependencies
	@brew remove swiftlint --force || true
	@brew install swiftlint

dependencies: submodules
	@bundle install

submodules:
	@git submodule sync --recursive || true
	@git submodule update --init --recursive || true
