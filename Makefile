## shallow clone for speed

REBAR_GIT_CLONE_OPTIONS += --depth 1
export REBAR_GIT_CLONE_OPTIONS

REBAR = rebar3

CT_NODE_NAME = emqxct@127.0.0.1

all: compile

compile: unlock
	$(REBAR) compile

clean: distclean

ct: compile
	$(REBAR) as test ct -v --readable=false --name $(CT_NODE_NAME)

eunit: compile
	$(REBAR) as test eunit

unlock:
	$(REBAR) unlock

xref:
	$(REBAR) xref

distclean:
	@rm -rf _build
	@rm -f data/app.*.config data/vm.*.args rebar.lock

CUTTLEFISH_SCRIPT = _build/default/lib/cuttlefish/cuttlefish

$(CUTTLEFISH_SCRIPT):
	@${REBAR} get-deps
	@if [ ! -f cuttlefish ]; then make -C _build/default/lib/cuttlefish; fi

app.config: $(CUTTLEFISH_SCRIPT) etc/emqx_bridge.conf
	$(verbose) $(CUTTLEFISH_SCRIPT) -l info -e etc/ -c etc/emqx_bridge.conf -i priv/emqx_bridge.schema -d data
