SOURCES=jslint-options.js array.js bind.js evt.js dom.js obj.js node.js ajaxer.js previewer.js main.js
TARGET=../main.js

all: $(TARGET)

lint: $(TARGET)
	java -jar ~/software/rhino1_7R2/js.jar ~/software/jslint/jslint.js $<

comp: $(TARGET)
	mv $(TARGET) tmp.js
	java -jar ~/software/yuicompressor-2.4.2/build/yuicompressor-2.4.2.jar --charset utf-8 --warn tmp.js -o $(TARGET)
	rm tmp.js

$(TARGET): $(SOURCES) Makefile
	cat $(SOURCES) > $@

