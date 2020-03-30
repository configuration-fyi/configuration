WEB_DIR           ?= website
WEBSITE_BASE_URL  ?= https://confiuration.fyi

# 0.55.3
HUGO              ?= $(shell which hugo)
ME				  ?= $(shell whoami)

.PHONY: all
all: web

define require_clean_work_tree
	@git update-index -q --ignore-submodules --refresh

    @if ! git diff-files --quiet --ignore-submodules --; then \
        echo >&2 "cannot $1: you have unstaged changes."; \
        git diff-files --name-status -r --ignore-submodules -- >&2; \
        echo >&2 "Please commit or stash them."; \
        exit 1; \
    fi

    @if ! git diff-index --cached --quiet HEAD --ignore-submodules --; then \
        echo >&2 "cannot $1: your index contains uncommitted changes."; \
        git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2; \
        echo >&2 "Please commit or stash them."; \
        exit 1; \
    fi

endef

web-pre-process:
	@rm -rf $(WEB_DIR)/copied > /dev/null
	@mkdir $(WEB_DIR)/copied
	@cp comparison.md $(WEB_DIR)/copied/
	@cp showcases.md $(WEB_DIR)/copied/
	@cp contributing.md $(WEB_DIR)/copied/

.PHONY: web
web: $(HUGO) web-pre-process
	@echo ">> building documentation website"
	# TODO(bwplotka): Make it --gc
	@cd $(WEB_DIR) && HUGO_ENV=production $(HUGO) --minify -v --config hugo.yaml -b $(WEBSITE_BASE_URL)

web-serve: $(HUGO) web-pre-process
	@echo ">> serving documentation website"
	@cd $(WEB_DIR) && $(HUGO) --config hugo.yaml -v server

# non-phony targets

$(HUGO):
	@echo "Install hugo, preferably in v0.54.0 version: https://gohugo.io/getting-started/installing/"

