# Автоматический активатор Office 2016

1. Скачайте консольный активатор **ConsoleAct_x64.exe** и в Defender укажите чтобы он его не трогал.
2. Запустите его и в его меню создайте задание в планировщике на реактивацию Office (задание будет с системной учетной записью **SYSTEM**)
3. Проверьте если ли в планировщие задание с именем KMSAuto которое запусает **ConsoleAct_x64.exe** с ключом **/ofs=act**
4. Также можно создать файл для запуска в свернутом режиме go.bat **start "" /MIN "C:\путь\к\вашей\activator.bat" ^& exit**. Данный скрипт в **ДЕЙСТВИЯ** пункта 5
5. Создайте в ручную задание в планировщике и задайте **ТРИГГЕР** - событие в журнале **ПРИЛОЖЕНИЯ** c **ID 1003**. Далее там же укажите **ДЕЙСТВИЯ** запуска bat файла который снизу.

Создайте файл activator.bat
```bat
@echo off
REM chcp 65001 >nul

setlocal enabledelayedexpansion
chcp 1251 >nul

title Проверка и активация Office
color 0A

set ACTIVATOR_TASK=KMSAuto
set MAX_RETRIES=1
set TIMEOUT_SEC=60

echo ====================================================
echo     Проверка и активация Microsoft Office
echo ====================================================
echo.

echo [1] Проверка активации Microsoft Office...
echo.

set OFFICE_ACTIVATED=0
set OFFICE_CHECKED=0

REM Проверяем 64-битную версию Office
if exist "%ProgramFiles%\Microsoft Office\root\Office16\ospp.vbs" (
    echo Обнаружена 64-битная версия Office
    cscript.exe //Nologo "%ProgramFiles%\Microsoft Office\root\Office16\ospp.vbs" /dstatus > "%TEMP%\office_status.txt"
    
    find /i "LICENSED" "%TEMP%\office_status.txt" >nul
    if errorlevel 1 (
        echo СТАТУС: Office не активирован
        set OFFICE_ACTIVATED=0
        
        REM Показываем детальный статус
        echo Детальный статус:
        type "%TEMP%\office_status.txt" | findstr /i "License Status Product"
    ) else (
        echo СТАТУС: Office активирован
        set OFFICE_ACTIVATED=1
        echo Детальный статус:
        type "%TEMP%\office_status.txt" | findstr /i "License Status Product"
    )
    set OFFICE_CHECKED=1
    del "%TEMP%\office_status.txt" >nul 2>&1
)

REM Проверяем 32-битную версию Office
if !OFFICE_CHECKED! equ 0 if exist "%ProgramFiles(x86)%\Microsoft Office\Office16\ospp.vbs" (
    echo Обнаружена 32-битная версия Office
    cscript.exe //Nologo "%ProgramFiles(x86)%\Microsoft Office\Office16\ospp.vbs" /dstatus > "%TEMP%\office_status.txt"
    
    find /i "LICENSED" "%TEMP%\office_status.txt" >nul
    if errorlevel 1 (
        echo СТАТУС: Office не активирован
        set OFFICE_ACTIVATED=0
        
        REM Показываем детальный статус
        echo Детальный статус:
        type "%TEMP%\office_status.txt" | findstr /i "License Status Product"
    ) else (
        echo СТАТУС: Office активирован
        set OFFICE_ACTIVATED=1
        echo Детальный статус:
        type "%TEMP%\office_status.txt" | findstr /i "License Status Product"
    )
    set OFFICE_CHECKED=1
    del "%TEMP%\office_status.txt" >nul 2>&1
)

if !OFFICE_CHECKED! equ 0 (
    echo ПРЕДУПРЕЖДЕНИЕ: Не удалось найти Office на компьютере
    set OFFICE_ACTIVATED=0
)

echo.

REM Если Office активирован - просто сообщаем и выходим
if !OFFICE_ACTIVATED! equ 1 (
    echo ====================================================
    echo Office уже активирован. Никаких действий не требуется.
    echo ====================================================
    timeout /t 3 /nobreak >nul
    exit /b 0
)

echo [2] Office не активирован. Запуск процедуры активации...
echo.

set ATTEMPT=0

:retry_loop
set /a ATTEMPT+=1
echo [Попытка активации %ATTEMPT% из %MAX_RETRIES%]
echo.

REM Закрытие Office приложений если запущены
echo Закрытие Office приложений если запущены...
taskkill /F /IM WINWORD.exe >nul 2>&1
taskkill /F /IM EXCEL.exe >nul 2>&1
taskkill /F /IM POWERPNT.exe >nul 2>&1
taskkill /F /IM OUTLOOK.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM Ожидание
echo Ожидание %TIMEOUT_SEC% сек перед активацией...
timeout /t !TIMEOUT_SEC! /nobreak >nul

REM Запуск активатора через задачу планировщика
echo Запуск задачи активации: %ACTIVATOR_TASK%
schtasks /run /tn "%ACTIVATOR_TASK%"

if errorlevel 1 (
    echo ОШИБКА: Не удалось запустить задачу активации
    goto :failed
)

echo Задача активации запущена. Ожидание 15 секунд...
timeout /t 15 /nobreak >nul

echo.
echo [3] Проверка результата активации...
echo.

set ACTIVATION_SUCCESS=0

REM Проверяем результат активации
if exist "%ProgramFiles%\Microsoft Office\root\Office16\ospp.vbs" (
    cscript.exe //Nologo "%ProgramFiles%\Microsoft Office\root\Office16\ospp.vbs" /dstatus | find /i "LICENSED" >nul
    if errorlevel 1 (
        echo Результат: Активация не удалась
        set ACTIVATION_SUCCESS=0
    ) else (
        echo Результат: Office успешно активирован!
        set ACTIVATION_SUCCESS=1
    )
) else if exist "%ProgramFiles(x86)%\Microsoft Office\Office16\ospp.vbs" (
    cscript.exe //Nologo "%ProgramFiles(x86)%\Microsoft Office\Office16\ospp.vbs" /dstatus | find /i "LICENSED" >nul
    if errorlevel 1 (
        echo Результат: Активация не удалась
        set ACTIVATION_SUCCESS=0
    ) else (
        echo Результат: Office успешно активирован!
        set ACTIVATION_SUCCESS=1
    )
)

REM Если активация успешна - сообщаем
if !ACTIVATION_SUCCESS! equ 1 (
    echo.
    echo ====================================================
    echo УСПЕХ: Office успешно активирован!
    echo Теперь вы можете запустить Word, Excel или другое
    echo приложение Office вручную.
    echo ====================================================
    timeout /t 3 /nobreak >nul
    exit /b 0
)

REM Если активация не удалась, пробуем снова
echo Активация не удалась.
if !ATTEMPT! LSS !MAX_RETRIES! (
    echo Повторная попытка активации...
    echo.
    goto :retry_loop
) else (
    goto :failed
)

:failed
echo.
echo ====================================================
echo ОШИБКА: Не удалось активировать Office
echo ====================================================
echo Обратитесь к системному администратору
echo.
pause
exit /b 1
```
