include theos/makefiles/common.mk

BUNDLE_NAME = FlatVibePrefs
FlatVibePrefs_FILES = FlatVibePrefs.mm
FlatVibePrefs_INSTALL_PATH = /Library/PreferenceBundles
FlatVibePrefs_FRAMEWORKS = UIKit
FlatVibePrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FlatVibePrefs.plist$(ECHO_END)
