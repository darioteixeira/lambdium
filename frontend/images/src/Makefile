TARGET1=../lambdium-banner.png

TARGETS=$(TARGET1)

all: $(TARGETS)

../%.png : %.svg Makefile
	inkscape -D -f $< -e $@ -h 30

