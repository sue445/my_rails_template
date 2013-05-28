#!/bin/bash

export LANG=ja_JP.UTF-8

rdoc --encoding UTF-8 --exclude lib/generators/ README.md lib/
