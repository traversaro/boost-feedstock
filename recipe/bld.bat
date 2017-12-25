:: Start with bootstrap
call bootstrap.bat
if errorlevel 1 exit 1

:: Build step
.\b2 install ^
    --build-dir=buildboost ^
    --prefix=%LIBRARY_PREFIX% ^
    toolset=msvc-%VS_MAJOR%.0 ^
    address-model=%ARCH% ^
    variant=release ^
    threading=multi ^
    link=static,shared ^
    -j%CPU_COUNT% ^
    --layout=system ^
    --without-python
if errorlevel 1 exit 1

:: Get the major minor version info (e.g. `1_61`)
python -c "import os; print('_'.join(os.environ['PKG_VERSION'].split('.')[:2]))" > temp.txt
set /p MAJ_MIN_VER=<temp.txt

:: Install fix-up for a non version-specific boost include
move %LIBRARY_INC%\boost-%MAJ_MIN_VER%\boost %LIBRARY_INC%
if errorlevel 1 exit 1

:: Remove Python headers as we don't build Boost.Python.
del %LIBRARY_INC%\boost\python.hpp
rmdir /s /q %LIBRARY_INC%\boost\python

:: Move dll's to LIBRARY_BIN
move %LIBRARY_LIB%\boost*.dll "%LIBRARY_BIN%"
if errorlevel 1 exit 1

echo &echo.                           >> %LIBRARY_INC%\boost\config\user.hpp
echo #define BOOST_AUTO_LINK_NOMANGLE >> %LIBRARY_INC%\boost\config\user.hpp

