@echo off
setlocal enabledelayedexpansion

REM Get the base URL for GitHub raw content
set "BASE_URL=https://img.tymski.pl/"

REM Create the JSON file
echo { > images.json
echo   "baseUrl": "%BASE_URL%", >> images.json
echo   "images": [ >> images.json

REM Counter for files
set "count=0"
set "first=1"

REM Find all image files and add them to the JSON
for /r %%f in (*.png *.jpg *.jpeg *.gif *.svg *.webp *.ico *.bmp) do (
    set "fullpath=%%f"
    set "filename=%%~nxf"
    set "extension=%%~xf"
    set "relpath=%%f"
    
    REM Get relative path by removing the base directory
    set "relpath=!fullpath:%CD%\=!"
    
    REM Replace backslashes with forward slashes for URL
    set "urlpath=!relpath:\=/!"
    
    REM Get the folder name
    set "folder=%%~dpf"
    set "folder=!folder:%CD%\=!"
    if "!folder!"=="!fullpath!" set "folder="
    if "!folder!"=="%%~dpf" set "folder="
    REM Remove trailing backslash from folder
    if not "!folder!"=="" set "folder=!folder:~0,-1!"
    
    REM Add comma before entries (except first)
    if !first!==0 (
        echo     , >> images.json
    )
    set "first=0"
    
    REM Add the file entry as JSON object
    echo     { >> images.json
    echo       "filename": "!filename!", >> images.json
    echo       "path": "!urlpath!", >> images.json
    echo       "folder": "!folder!", >> images.json
    echo       "extension": "!extension!" >> images.json
    echo     } >> images.json
    
    set /a count+=1
)

REM Close the JSON
echo   ] >> images.json
echo } >> images.json

echo Build complete! Generated images.json with %count% images.
