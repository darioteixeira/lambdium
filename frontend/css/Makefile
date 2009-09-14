THEME=aquamarine

all: $(AQUAMARINE)/default.css

$(AQUAMARINE)/main.css: $(AQUAMARINE)/*.less
	lessc $(AQUAMARINE)/main.less $@

$(AQUAMARINE)/default.css: $(AQUAMARINE)/main.css
	csstidy $< $@ --silent=true

