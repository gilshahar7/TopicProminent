FINALPACKAGE = 1
ARCHS = arm64 armv7 armv7s
export TARGET = :clang:11.2:9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TopicProminent
TopicProminent_FILES = Tweak.xm
TopicProminent_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += topicprominentprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
