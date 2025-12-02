@echo off
setlocal EnableDelayedExpansion

:: --- Enter the manga title
set /p "manga=Enter Manga title: "
set "mangaName=!manga: =_!"

:: --- Enter the first chapter
set /p "minChapter=Enter the first chapter: "

:: --- Enter the last chapter
set "maxChapter=%minChapter%"
set /p "maxChapter=Enter the last chapter: "

:: --- Wanna read first?
set /p "alsoRead=Want to read? (y/n) "

:: --- Make folder if dont exist
if not exist "%manga%" (
    mkdir "%manga%"
)

:: --- Sat Set
set "totalError=0"

echo:
:: --- Start
for /L %%c in (%minChapter%,1,%maxChapter%) do (
    
    :: --- Sat Set
    set "chapter=%%c"
    set "endOfPage=false"

    <nul set /p="Downloading '%manga%' chapter %%c..."

    for /L %%p in (1,1,1000) do (
        if "!endOfPage!" == "false" (
            
            :: --- Sat Set
            set "fileName=%mangaName%_%%c_%%p.jpg"
            set "page=%%p"
            
            :: --- Download image
            curl -s -o "!fileName!" "https://images.mangafreak.me/mangas/%mangaName%/%mangaName%_%%c/%mangaName%_%%c_%%p.jpg"
            
            :: --- If the end of page
            for %%A in ("!fileName!") do set fileSize=%%~zA
            if !fileSize! == 5 (
                del /q "!fileName!"
                set "endOfPage=true"
            )
        )
    )

    :: --- Check is chapter exist!
    if !page! GTR 1 (
        :: --- Zip image files for the current chapter
        "C:\Program Files\7-Zip\7z.exe" a -tzip "%mangaName%_!chapter!.zip" "%mangaName%_!chapter!_*.jpg" -y >nul 2>&1
        
        :: --- Move to folder
        move /Y "%mangaName%_!chapter!.zip" "%manga%\" >nul 2>&1

        :: --- Then delete them if you don't want to read it after
        if   "%alsoRead%"=="n" (
            del /q "%mangaName%_!chapter!_*.jpg" >nul 2>&1
        )

        echo done
    ) else (
        set /a totalError+=1
        echo ERROR
    )
)

:: --- Some calc
set /a totalDone=maxChapter-minChapter+1-totalError

:: Show message all done!
echo:
echo All done fam.
echo %totalDone% downloaded, %totalError% error.
echo:

endlocal
pause