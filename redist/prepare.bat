@echo off

del Blossom\hlboot.dat
del *.zip
del *.swf
del *.js

cd ..
echo HL...
haxe hl.hxml

echo Flash...
haxe flash.hxml

echo JS...
haxe js.hxml

echo Copying...
copy bin\client.hl redist\Blossom\hlboot.dat
copy bin\client.swf redist
copy bin\client.js redist
pause