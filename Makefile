.PHONY: clean
clean:
		rm -rf public

.PHONY: start
start: clean
		hugo server -v -D

.PHONY: build
build:
		hugo -v

.PHONY: publish
publish:
		sh ./publish-to-gh-pages.sh
