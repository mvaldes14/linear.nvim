fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=stylua.toml

lint:
	echo "===> Linting"
	luacheck lua/ --globals vim

test:
	echo "===> Testing"
	nvim --headless --noplugin -u lua/linear/test/minimal.vim -c "PlenaryBustedDirectory lua/linear/test/ {minimal_init = 'lua/linear/test/minimal.vim'}"

clean:
	echo "===> Cleaning"
	rm /tmp/lua_*

pr-ready: fmt lint test
