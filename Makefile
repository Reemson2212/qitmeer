
EXECUTABLE := qitmeer
GITVERSION := $(shell git rev-parse --short HEAD)
DEV=dev
RELEASE=release
LDFLAG_DEV = -X github.com/Qitmeer/qitmeer/version.Build=$(DEV)-$(GITVERSION)
LDFLAG_RELEASE = -X github.com/Qitmeer/qitmeer/version.Build=$(RELEASE)
GOFLAGS_DEV = -ldflags "$(LDFLAG_DEV)"
GOFLAGS_RELEASE = -ldflags "$(LDFLAG_RELEASE)"
VERSION=$(shell ./build/bin/qitmeer --version | grep ^qitmeer | cut -d' ' -f3|cut -d'+' -f1)

#target-dash=$(word $2,$(subst /, ,$1))


UNIX_EXECUTABLES := \
	build/release/darwin/amd64/bin/$(EXECUTABLE) \
	build/release/linux/amd64/bin/$(EXECUTABLE)
WIN_EXECUTABLES := \
	build/release/windows/amd64/bin/$(EXECUTABLE).exe

EXECUTABLES=$(UNIX_EXECUTABLES) $(WIN_EXECUTABLES)
	
COMPRESSED_EXECUTABLES=$(UNIX_EXECUTABLES:%=%.tar.gz) $(WIN_EXECUTABLES:%.exe=%.zip)

RELEASE_TARGETS=$(EXECUTABLES) $(COMPRESSED_EXECUTABLES)

.PHONY: qitmeer qx release

qitmeer: 
	@go build -o ./build/bin/qitmeer $(GOFLAGS_DEV) "github.com/Qitmeer/qitmeer/cmd/qitmeerd"

qx:
	@go build -o ./build/bin/qx "github.com/Qitmeer/qitmeer/cmd/qx"

checkversion: qitmeer 
	@echo version $(VERSION)

all : qitmeer qx 

# amd64 release
build/release/%: OS=$(word 3,$(subst /, ,$(@)))
build/release/%: ARCH=$(word 4,$(subst /, ,$(@)))
build/release/%/$(EXECUTABLE):
	@echo build $(@) 
	@GOOS=$(OS) GOARCH=$(ARCH) go build $(GOFLAGS_RELEASE) -o $(@) "github.com/Qitmeer/qitmeer/cmd/qitmeerd"
build/release/%/$(EXECUTABLE).exe:
	@echo build $(@) 
	@GOOS=$(OS) GOARCH=$(ARCH) go build $(GOFLAGS_RELEASE) -o $(@) "github.com/Qitmeer/qitmeer/cmd/qitmeerd"

#build/release/linux/amd64/bin/$(EXECUTABLE):
#	GOOS=$(OS) GOARCH=$(ARCH) go build $(GOFLAGS_RELEASE) -o $(@) "github.com/Qitmeer/qitmeer/cmd/qitmeerd"
#build/release/windows/amd64/bin/$(EXECUTABLE).exe:
#	GOOS=$(OS) GOARCH=$(ARCH) go build $(GOFLAGS_RELEASE) -o $(@) "github.com/Qitmeer/qitmeer/cmd/qitmeerd"
#
#
#qitmeer-%: OS=$(call target-dash,$(*),1)
#qitmeer-%: ARCH=$(call target-dash,$(*),2)
#qitmeer-%: OUT=./build/$(RELEASE)/$(OS)/$(ARCH)/bin/qitmeer
#qitmeer-%:
#	GOOS=$(OS) GOARCH=$(ARCH) go build $(GOFLAGS_RELEASE) -o $(OUT) "github.com/Qitmeer/qitmeer/cmd/qitmeerd"
#qitmeer-all: qitmeer-darwin-amd64 qitmeer-windows-amd64 qitmeer-linux-amd64
#	@echo "Full cross compilation done"

%.zip: %.exe
#	@echo target=$(@)
#	@echo OS=$(OS)
#	@echo ARCH=$(ARCH)
#	@echo VERSION=$(VERSION)
	@echo zip $(EXECUTABLE)-$(VERSION)-$(OS)-$(ARCH)
	@zip $(EXECUTABLE)-$(VERSION)-$(OS)-$(ARCH).zip "$<"
%.tar.gz : %
#	@echo target=$(@)
	@echo tar $(EXECUTABLE)-$(VERSION)-$(OS)-$(ARCH)
	@tar -zcvf $(EXECUTABLE)-$(VERSION)-$(OS)-$(ARCH).tar.gz "$<"
release: clean checkversion
#	@echo $(RELEASE_TARGETS)
	@$(MAKE) $(RELEASE_TARGETS)
	@shasum -a 512 $(EXECUTABLES)
	@shasum -a 512 qitmeer-*
clean:
	@rm -f *.zip
	@rm -f *.tar.gz
	@rm -f ./build/bin/qx
	@rm -f ./build/bin/qitmeer
	@rm -rf ./build/release
