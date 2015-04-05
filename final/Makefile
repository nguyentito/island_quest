# -*- Makefile -*-

lib_TARGETS = champion

# Tu peux rajouter des fichiers .ml ou changer les flags de ocamlc
# Les fichiers .mli correspondants seront automatiquement utilises si
# existants.
champion-srcs = api.ml prologin.ml
champion-camlflags = -g

# Evite de toucher a ce qui suit
champion-dists = interface.hh
champion-srcs += interface.cc
include ../includes/rules.mk
