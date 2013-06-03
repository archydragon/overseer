REBAR=rebar
.DEFAULT_GOAL := all
.PHONY: all deps compile clean run

all: compile

deps:
	$(REBAR) get-deps

compile: deps
	$(REBAR) compile

clean:
	rm -rf deps ebin erl_crash.dump

run:
	erl -pa ebin -pa deps/*/ebin -s overseer