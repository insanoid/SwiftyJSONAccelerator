WORKSPACE = SwiftyJSONAccelerator.xcworkspace
PROJECT = SwiftyJSONAccelerator.xcodeproj
TEMPORARY_FOLDER?=/tmp/SwiftyJSONAccelerator.dst/
TEMPORARY_FOLDER_CLI?=/tmp/SwiftyJSONAccelerator-CLI.dst/
BUILD_TOOL?=xcodebuild
PIPE_FAIL = set -o pipefail &&
XCPRETTY = | xcpretty -s

APP_SCHEME = "SwiftyJSONAccelerator"
CLI_SCHEME = "SJAccelerator - CLI"
APP_NAME = SwiftyJSONAccelerator.app
CLI_NAME = swiftyjsonaccelerator
APP_INSTALLATION_PATH = /Applications/
CLI_INSTALLATION_PATH = /usr/local/bin/

XCODEFLAGS_APP=-workspace $(WORKSPACE) \
	-scheme $(APP_SCHEME) \
	CODE_SIGN_IDENTITY="" \
	CODE_SIGNING_REQUIRED=NO \
	CONFIGURATION_BUILD_DIR=$(TEMPORARY_FOLDER)

XCODEFLAGS_CLI=-workspace $(WORKSPACE) \
	-scheme $(CLI_SCHEME) \
	CODE_SIGN_IDENTITY="" \
	CODE_SIGNING_REQUIRED=NO \
	CONFIGURATION_BUILD_DIR=$(TEMPORARY_FOLDER_CLI)


# Format the folder structure.
synxify:
	@bundle exec synx -p \
	-e "Core/External-Libraries" \
	-e "SwiftyJSONAccelerator-CLI/External-Libraries" \
	$(PROJECT)

# Clean the projects.
clean:
	@rm -rf "$(TEMPORARY_FOLDER)"
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Debug clean $(XCPRETTY)
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Release clean $(XCPRETTY)
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Test clean $(XCPRETTY)
	@$(BUILD_TOOL) $(XCODEFLAGS_CLI) -configuration Debug clean $(XCPRETTY)
	@$(BUILD_TOOL) $(XCODEFLAGS_CLI) -configuration Release clean $(XCPRETTY)
	@$(BUILD_TOOL) $(XCODEFLAGS_CLI) -configuration Test clean $(XCPRETTY)

# Run test for the app.
test:
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Test | tee xcodebuild.log $(XCPRETTY)
	@slather coverage --show --html --scheme $(APP_SCHEME) $(PROJECT)
	@rm xcodebuild.log

install: bootstrap uninstall
# CLI
	@$(BUILD_TOOL) $(XCODEFLAGS_CLI) -configuration Release $(XCPRETTY)
	@cp $(TEMPORARY_FOLDER_CLI)$(CLI_NAME) $(CLI_INSTALLATION_PATH)
# Application
	@$(BUILD_TOOL) $(XCODEFLAGS_APP) -configuration Release $(XCPRETTY)
	@cp -r $(TEMPORARY_FOLDER)$(APP_NAME) $(APP_INSTALLATION_PATH)$(APP_NAME)

	@echo " ✓ SwiftyJSONAccelerator app and CLI successfully installed!! 🍻 "
	@echo " ✓ Use the app from Applications or ./"$(CLI_NAME)

uninstall:
	@rm -rf $(APP_INSTALLATION_PATH)$(APP_NAME)
	@rm -f $(CLI_INSTALLATION_PATH)$(CLI_NAME)

bootstrap: dependencies
	@brew remove swiftlint --force || true
	@brew install swiftlint

dependencies: gitsubmodules
	@bundle install

gitsubmodules:
	@git submodule sync --recursive || true
	@git submodule update --init --recursive || true
