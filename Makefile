ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TurathStore
TurathStore_FILES = Tweak.xm
TurathStore_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
TurathStore_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
