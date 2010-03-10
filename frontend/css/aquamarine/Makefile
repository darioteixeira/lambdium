IMAGES=images/lambdium-logo.png
SOURCES=reset.ccss config.ccss style.ccss layout.ccss header.ccss footer.ccss core.ccss margins.ccss

all: main.css $(IMAGES)

main.css: $(SOURCES)
	cat $(SOURCES) | ccss > $@
	#csstidy tmp.css $@ --silent=true

images/lambdium-logo.png: images/src/lambdium-logo.svg
	inkscape -f $< -e $@ -w 120

clean:
	rm -f main.css $(IMAGES)

