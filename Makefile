## dcape-app-template Makefile
## This file extends Makefile.app from dcape
#:

SHELL               = /bin/bash
CFG                ?= .env
CFG_BAK            ?= $(CFG).bak

#- App name
APP_NAME           ?= asterisk

#- Docker image name
IMAGE              ?= mlan/asterisk

#- Docker image tag
IMAGE_VER          ?= latest

# If you need database, uncomment this var
#USE_DB              = yes

# If you need user name and password, uncomment this var
#ADD_USER            = yes

#- extension password
EXTPASSWORD        ?= $(shell openssl rand -hex 8; echo)

#- app root
APP_ROOT           ?= $(PWD)

# Copy from image to persist dir (always)
PERSIST_FILES       = asterisk
# Keep persistent dir on deploy
APP_ROOT_OPTS       = keep

# ------------------------------------------------------------------------------

# if exists - load old values
-include $(CFG_BAK)
export

-include $(CFG)
export

# ------------------------------------------------------------------------------
# Find and include DCAPE_ROOT/Makefile
DCAPE_COMPOSE   ?= dcape-compose
DCAPE_ROOT      ?= $(shell docker inspect -f "{{.Config.Labels.dcape_root}}" $(DCAPE_COMPOSE))

ifeq ($(shell test -e $(DCAPE_ROOT)/Makefile.app && echo -n yes),yes)
  include $(DCAPE_ROOT)/Makefile.app
else
  include /opt/dcape/Makefile.app
endif

# ------------------------------------------------------------------------------

## Template support code, used once
use-template:

.default-deploy: prep

prep: asterisk/pjsip.conf

asterisk/pjsip.conf: .env asterisk/pjsip.conf.tmpl
	sed -e "s|=PASSWORD=|$$EXTPASSWORD|g" $@.tmpl > $@