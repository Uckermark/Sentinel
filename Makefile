
INSTALL_TARGET_PROCESSES = SpringBoard
export ARCHS = arm64 # arm64e
export TARGET=iphone:clang:latest:15.0
export GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Sentinel

Sentinel_FILES = Tweak.xm 
Sentinel_FRAMEWORKS += UIKit QuartzCore IOKit CoreFoundation
Sentinel_CODESIGN_FLAGS = -Sent.xml
Sentinel_EXTRA_FRAMEWORKS += Cephei
Sentinel_PRIVATE_FRAMEWORKS = MediaRemote
Sentinel_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += deepsleep
SUBPROJECTS += pref
SUBPROJECTS += cc

include $(THEOS_MAKE_PATH)/aggregate.mk
