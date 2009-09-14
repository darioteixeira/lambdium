#
# Makefile for Lambdium project.
# Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
# This software is distributed under the terms of the GNU GPL v2.
# See LICENSE file for full license text.
#


#export PGHOST=
#export PGPORT=
#export PGUSER=
#export PGPASSWORD=
export PGDATABASE=lambdium
#export UNIX_DOMAIN_SOCKET_DIR=


OCAMLBUILD_OPTS=
SRC_DIR=src
TARGETS=lambdium.native lambdium.byte


#
# Rules
#

all: bin

bin:
	cd $(SRC_DIR) && ocamlbuild $(OCAMLBUILD_OPTS) $(TARGETS)

apidoc: bin
	cd $(SRC_DIR) && ocamlbuild $(OCAMLBUILD_OPTS) lambdoc.docdir/index.html
	cp $(SRC_DIR)/apidoc/style.css $(SRC_DIR)/lambdoc.docdir

clean:
	cd $(SRC_DIR) && ocamlbuild $(OCAMLBUILD_OPTS) -clean

