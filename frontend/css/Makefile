IMAGES=images/lambdium-logo.png
SOURCES=reset.ccss config.ccss global.ccss header.ccss footer.ccss margins.ccss core.ccss embedded_lambdoc.css

all: main.css $(IMAGES)

main.css: $(SOURCES)
	cat $+ | ccss > $@

images/lambdium-logo.png: images/src/lambdium-logo.svg
	inkscape -f $< -e $@ -w 120

clean:
	rm -f main.css $(IMAGES)

