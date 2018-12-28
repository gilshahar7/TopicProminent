GO_EASY_ON_ME = 1
ARCHS = arm64 armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TopicProminent
TopicProminent_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += topicprominentprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
