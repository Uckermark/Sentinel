include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SentinelPref
SentinelPref_FILES = SentRootListController.m
SentinelPref_INSTALL_PATH = /Library/PreferenceBundles
SentinelPref_FRAMEWORKS = UIKit

SentinelPref_PRIVATE_FRAMEWORKS = Preferences
SentinelPref_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SentinelPref.plist$(ECHO_END)
