#!/bin/bash

dd if=$1 conv=ucase  |sed 's/ /_/g'|sed 's/./        retlw _&\n/g' |sed 's/É/Eaigu/g' |sed 's/È/Egrave/g'|sed 's/À/Agrave/g' |sed 's/Ç/Ccedil/g'|sed 's/!/exclam/g' > $1.inc

