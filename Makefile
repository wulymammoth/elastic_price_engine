# watches for file changes and runs tests
test-watch:
	watchman-make -p 'lib/**/*.ex' 'test/**/*.exs' -t test
.PHONY: test-watch

# clears screen
clear:
	clear
.PHONY: clear

# runs test suite
test:
	clear
	mix test
.PHONY: test
