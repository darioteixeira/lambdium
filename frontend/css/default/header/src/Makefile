TARGET1=../lambdium-logo.png

TARGETS=$(TARGET1)

all: $(TARGETS)

../%.png : %.svg Makefile
	inkscape -f $< -e $@ -w 120

