export TARGET=iphone:clang:latest:15.0
export ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Sentinel

Sentinel_FILES = Tweak.xm 
Sentinel_FRAMEWORKS += UIKit
Sentinel_CODESIGN_FLAGS = -Sent.xml
Sentinel_EXTRA_FRAMEWORKS += Cephei
Sentinel_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += deepsleep
SUBPROJECTS += pref
SUBPROJECTS += cc

include $(THEOS_MAKE_PATH)/aggregate.mk
