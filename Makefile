SRC=$(shell find src -name '*.hs')

CABAL=stack
FLAGS=--enable-tests

all: init test docs package

init: stack.yaml

stack.yaml:
	stack init --prefer-nightly

test: build
	stack test


run: build
	stack exec -- c18sgml --help

data/c18-utf8.sgm: data/c18.sgm
	iconv -f ISO-8859-1 -t UTF-8 < $< > $@

data/c18-utf8.xml: data/c18-utf8.sgm build
	stack exec -- c18sgml denest --input $< --output $@ --tag pb
	stack exec -- c18sgml report < $@ 2> debug-xml.out

xmllint: data/c18-utf8.xml

debug.out: data/c18-utf8.sgm build
	stack exec -- c18sgml report < $< 2> $@

# docs:
# generate api documentation
#
# package:
# build a release tarball or executable
#
# dev:
# start dev server or process. `vagrant up`, `yesod devel`, etc.
#
# deploy:
# prep and push

configure:
	cabal configure --package-db=clear --package-db=global --package-db=`stack path --snapshot-pkg-db` --package-db=`stack path --local-pkg-db`

install:
	stack install

tags: ${SRC}
	codex update

hlint:
	hlint *.hs src specs

clean:
	stack clean
	codex cache clean
	-rm -f data/c18-utf8.sgm

distclean: clean

build:
	stack build --pedantic

watch:
	ghcid "--command=stack ghci"

restart: distclean init build

rebuild: clean build

.PHONY: all init configure test run clean distclean build rebuild hlint watch tags xmllint
