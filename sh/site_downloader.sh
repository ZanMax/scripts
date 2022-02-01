#!/bin/bash
wget --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 11_1_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.96 Safari/537.36" -e robots=off -r -k -l 7 -p -E -nc $1
