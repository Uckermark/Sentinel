include $(THEOS)/makefiles/common.mk

TOOL_NAME = SentinelRunner

SentinelRunner_FILES = main.m
SentinelRunner_FRAMEWORKS += IOKit
SentinelRunner_CFLAGS = -fobjc-arc
SentinelRunner_CODESIGN_FLAGS = -Sent.xml

include $(THEOS_MAKE_PATH)/tool.mk
