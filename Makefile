fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=stylua.toml

lint:
	echo "===> Linting"
	luacheck lua/ --globals vim

test:
	echo "===> Testing"
	nvim --headless --noplugin -u test/minimal.vim \
        -c "PlenaryBustedDirectory test/ {minimal_init = 'test/minimal.vim'}"

clean:
	echo "===> Cleaning"
	rm /tmp/lua_*

pr-ready: fmt lint test
