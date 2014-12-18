export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = FlatVibe
FlatVibe_FILES = Tweak.xm
FlatVibe_FRAMEWORKS = CoreMotion
FlatVibe_LIBRARIES = flipswitch

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall SpringBoard"
SUBPROJECTS += flatvibeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
