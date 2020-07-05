# watches for file changes and runs tests
test-watch:
	watchman-make -p 'lib/**/*.ex' 'test/**/*.exs' -t test
.PHONY: test-watch

# runs test suite
test:
	mix test
.PHONY: test
