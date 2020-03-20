#!/bin/bash

aws s3 sync --quiet $1 s3://thec3-online-dump/
