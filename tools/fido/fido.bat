SET BASEDIR=%~dp0
SET FIDO_PROG="%BASEDIR%\fido.py"

python "%FIDO_PROG%" -bufsize 1000000 -container_bufsize 1000000 -q "$@"