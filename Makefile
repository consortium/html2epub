# check for cygwin, get paths
ifeq ($(shell uname -o),Cygwin)
get-fullpath	= $(shell cygpath -ma "$(1)")
get-uri		= $(shell echo file:///$(call get-fullpath,$(1))  | sed -r 's/ /%20/g')
else
get-fullpath	= $(shell readlink -f "$(1)")
get-uri		= $(shell echo $(abspath $(1)) )
endif

# default values

IN_FILE_BASE	= $(basename $(notdir $(IN_FILE)))
OUT_DIR		= output/$(notdir $(IN_FILE))
OUT_DIR_PATH	= $(call get-fullpath,$(OUT_DIR))
IN_FILE_COPY	= $(OUT_DIR_PATH)/$(notdir $(IN_FILE))
MAKEFILE_DIR	= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
CALABASH	= $(MAKEFILE_DIR)/calabash/calabash.sh
DEBUG		= yes
DEBUG_DIR	= $(OUT_DIR_PATH)/debug
DEBUG_DIR_URI	= $(call get-uri,$(DEBUG_DIR))
STATUS_DIR	= $(OUT_DIR_PATH)/status
STATUS_DIR_URI	= $(call get-uri,$(STATUS_DIR))
HEAP		= 1024m
DEVNULL		= $(call get-fullpath,/dev/null)

usage:

	@echo "Usage (one of):"
	@echo "  make conversion IN_FILE=myfile.docx"
	@echo "  make conversion IN_FILE=myfile.idml"
	@echo ""
	@echo "  Sample file invocations:"
	@echo "  make conversion IN_FILE=../content/le-tex/whitepaper/de/transpect_wp_de.docx DEBUG=yes"
	@echo ""

messages:
	@echo ""
	@echo "Makefile target: messages"
	@echo ""
	@echo "BASENAME:		$(IN_FILE_BASE)"
	@echo "OUT_DIR:			$(OUT_DIR_PATH)"
	@echo "MAKEFILE_DIR:		$(MAKEFILE_DIR)"
	@echo "CALABASH:		$(CALABASH)"
	@echo "DEBUG:			$(DEBUG)"
	@echo "DEBUG_DIR:		$(DEBUG_DIR)"
	@echo "STATUS_DIR:		$(STATUS_DIR)"

checkinput:
	@echo ""
	@echo "Makefile target: checkinput"
	@echo ""
ifeq ("$(wildcard $(IN_FILE))","")
	@echo "[ERROR] File not found. Please check IN_FILE"
	exit 1
else
	@echo "File exists $(IN_FILE)"
endif

preprocess:
	@echo ""
	@echo "Makefile target: preprocess"
	@echo ""
	-rm -rf $(OUT_DIR_PATH)
	-mkdir -p $(OUT_DIR_PATH)
	-mkdir -p $(DEBUG_DIR)
	-mkdir -p $(STATUS_DIR)
	-cp $(IN_FILE) $(IN_FILE_COPY)

html2epub:
	@echo ""
	@echo "Makefile target: html2epub"
	@echo ""
	HEAP=$(HEAP) $(CALABASH) -D \
		-o htmlreport=$(OUT_DIR_PATH)/report.xhtml \
		-o result=$(DEBUG_DIR)/result.xml \
		$(call get-uri,a9s/common/xpl/html2epub.xpl)\
		file=$(IN_FILE_COPY) \
		status-dir-uri=$(STATUS_DIR_URI) \
		debug-dir-uri=$(DEBUG_DIR_URI) \
		debug=$(DEBUG) \

postprocess:
	@echo ""
	@echo "Makefile target: postprocess"
	@echo ""
ifneq ($(DEBUG),yes)
#	-rm -rf $(IN_FILE_COPY).tmp
	-rm -rf $(OUT_DIR_PATH)/result
#	-rm -rf $(DEBUG_DIR)
	-rm -rf $(STATUS_DIR)
endif

#archive:
#	@echo ""
#	@echo "Makefile target: archive"
#	@echo ""
#	# delete temporary zip files
#	-rm $(OUT_DIR_PATH)/$(IN_FILE_BASE).zip
#	cd $(OUT_DIR_PATH) && zip -r $(OUT_DIR_PATH)/$(IN_FILE_BASE).zip ./*

conversion: messages checkinput preprocess html2epub postprocess 
	@echo ""
	@echo "Makefile target: conversion FINISHED"
	@echo ""

progress:
	@ls -1rt $(STATUS_DIR)/*.txt | xargs -d'\n' -I § sh -c 'date "+%H:%M:%S " -r § | tr -d [:cntrl:]; cat §'
