@echo off

setlocal
set PUB_HOSTED_URL=
set FLUTTER_STORAGE_BASE_URL=

call set_proxyhttp

call dart pub publish --dry-run

pause
call dart pub publish