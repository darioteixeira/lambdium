SOURCES=jslint-options.js array.js bind.js evt.js dom.js obj.js node.js ajaxer.js previewer.js main.js
TARGET=../main.js
MIDDLE=../middle.js

all: $(TARGET)

lint: $(TARGET)
	java -jar ~/software/rhino1_6R7/js.jar ~/software/jslint/jslint.js $<

comp: $(MIDDLE)
	java -jar ~/software/yuicompressor-2.2.4/build/yuicompressor-2.2.4.jar --warn -o $(TARGET) $<

$(TARGET): $(MIDDLE)
	sed -e "s/^const/var/" -i $<
	cp $< $@
	unix2dos $@
	
$(MIDDLE): $(SOURCES) Makefile
	cat $(SOURCES) > $@

