@echo off
setlocal enabledelayedexpansion

REM Check if ffprobe is available in PATH
where ffprobe >nul 2>nul
if %errorlevel% neq 0 (
    echo Warning: ffprobe not found in PATH. Width and height will be set to null.
)

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
    set "size=%%~zf"
    set "relpath=%%f"
    
    REM Initialize dimensions as null (in case ffprobe fails or file is unsupported)
    set "width=null"
    set "height=null"
    
    REM Try to get dimensions using ffprobe
    REM Note: We escape the comma and equals signs with ^ so batch doesn't misinterpret them
    for /f "tokens=1,2 delims=," %%w in ('ffprobe -v error -select_streams v:0 -show_entries stream^=width^,height -of csv^=p^=0 "%%~f" 2^>nul') do (
        set "width=%%w"
        set "height=%%x"
    )
    
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
    echo       "extension": "!extension!", >> images.json
    echo       "size": !size!, >> images.json
    echo       "width": !width!, >> images.json
    echo       "height": !height! >> images.json
    echo     } >> images.json
    
    set /a count+=1
)

REM Close the JSON
echo   ] >> images.json
echo } >> images.json

echo Build complete! Generated images.json with %count% images.