git pull --recurse-submodules
git submodule update --init --recursive
pushd deps\HudController_util
call build.bat
popd
md bin\reframework\plugins
robocopy reframework bin/reframework /mir
robocopy deps\HudController_util\bin bin\reframework\plugins hudcontroller_util.dll
tar -a -cf HudController.zip -C bin reframework
rmdir /s /q bin