IMAGES=images/lambdium-logo.png

all: default.css $(IMAGES)

default.css: *.less
	lessc main.less tmp.css
	csstidy tmp.css $@ --silent=true
	rm tmp.css

images/lambdium-logo.png: images/src/lambdium-logo.svg
	inkscape -f $< -e $@ -w 120

clean:
	rm -f default.css $(IMAGES)

