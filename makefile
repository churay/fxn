### Compilation/Linking Tools and Flags ###

LUA_PROJ_RUNNER = love
LUA_PROJ_RUNNER_FLAGS =
LUA_TESTER = busted
LUA_TESTER_FLAGS = --lpath='$(LUA_DIR)/?.lua;$(PROJ_DIR)/?/init.lua;$(TEST_DIR)/?.lua'

### Project Files and Directories ###

PROJ_DIR = .
BIN_DIR = $(PROJ_DIR)/bin
LUA_DIR = $(PROJ_DIR)/fxn
TEST_DIR = $(PROJ_DIR)/spec

FXN_DIST = $(BIN_DIR)/fxn
FXN_EXE = $(BIN_DIR)/fxn/fxn.exe
FXN_LOVE = $(BIN_DIR)/fxn.love

### Build Rules ###

.PHONY : dist love main tests %Test clean

all : main

$(FXN_DIST) dist : $(FXN_LOVE)
	wget -O $(BIN_DIR)/love.zip https://bitbucket.org/rude/love/downloads/love-0.10.0-win32.zip
	unzip -d $(BIN_DIR) $(BIN_DIR)/love.zip
	mv $(BIN_DIR)/love-0.10.0-win32 $(FXN_DIST)
	cat $(FXN_DIST)/love.exe $(FXN_LOVE) > $(FXN_EXE)

$(FXN_LOVE) love : $(wildcard $(PROJ_DIR)/*.lua) $(wildcard $(LUA_DIR)/*.lua)
	zip -9 -q -r $(FXN_LOVE) $(PROJ_DIR)

main :
	$(LUA_PROJ_RUNNER) $(LUA_PROJ_RUNNER_FLAGS) $(PROJ_DIR)

tests : $(wildcard $(LUA_DIR)/*.lua) $(wildcard $(TEST_DIR)/*.lua)
	$(LUA_TESTER) $(LUA_TESTER_FLAGS) --pattern='Spec' $(TEST_DIR)

%Test : $(TEST_DIR)/%Spec.lua
	$(LUA_TESTER) $(LUA_TESTER_FLAGS) --pattern='$(basename $(<F))' $(TEST_DIR)

clean :
	rm -rf $(BIN_DIR)/*
