;NSIS Modern User Interface
;Multilingual Example Script
;Written by Jesper Nørgaard Welen

;--------------------------------
;Include Modern UI

   SetCompressor lzma

  !include "MUI.nsh"
  !include "NSISArray.nsh"
  !include "LogicLib.nsh"
  !include "FileFunc.nsh"
  !include "WordFunc.nsh"
  !include "TextFunc.nsh"
  !insertmacro GetDrives
  !insertmacro un.GetDrives
  !insertmacro WordReplace
  !insertmacro LineRead
  Var /Global Crop
  Var /Global UserName
  Var /Global Password
  Var /Global CDdrive
  Var /Global MappedDrive
  ; Variables to pass from central GMS to local GMS
  Var /Global Upswd
  Var /Global Adate
  Var /Global Userid
  Var /Global Instalid
  Var /Global Idesc
  Var /Global LocalUserid

  ${Array} "MyArray" 30 50
  ${ArrayFunc} Write
  ${ArrayFunc} Read

;--------------------------------
;General

  ShowInstDetails show

  Page custom SetCustom ValidateCustom ; Let user type in Crop, UserName, and Password
  ;Name and file
  Name "IWIS3"
  OutFile "IWIS3-2007-05-30.exe"

  ;Default installation folder
  InstallDir "C:\ICIS5"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\IWIS3" ""

  ReserveFile "UserPassword.ini"
  ReserveFile "${NSISDIR}\Plugins\InstallOptions.dll"

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_LANGDLL_ALWAYSSHOW

;--------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU" 
  !define MUI_LANGDLL_REGISTRY_KEY "Software\IWIS3"
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE "C:\ICIS5\Setup\WISE\Readme.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "Spanish" ;first language is the default language
  !insertmacro MUI_LANGUAGE "English"
  !insertmacro MUI_LANGUAGE "Danish"

;--------------------------------
;Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
;Installer Sections

Function .onInit
  ;Messagebox MB_OK "ON INIT section"
  !insertmacro MUI_LANGDLL_DISPLAY
  InitPluginsDir
  File /oname=$PLUGINSDIR\UserPassword.ini UserPassword.ini
  ${Switch} $LANGUAGE
    ${Case} ${LANG_SPANISH}
      MessageBox MB_OKCANCEL "Bienvenido a la instalación del programa IWIS3 (versión ICIS) en su computadora. Esto es versión 5.4 de ICIS. Haga click en OK para comenzar la instalación. $\r$\n$\r$\nPuede hacer click en Cancelar si no quiere instalar el programa." IDOK true IDCANCEL false
      ${Break}
    ${Case} ${LANG_DANISH}
      MessageBox MB_OKCANCEL "Velkommen til installationen af IWIS3 (ICIS version) i din computer. Dette er version 5.4 af ICIS. Tryk OK for at starte installationen. $\r$\n$\r$\nDu kan trykke Fortryd hvis du ikke vil installere programmet." IDOK true IDCANCEL false
      ${Break}
    ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
      MessageBox MB_OKCANCEL "This program will install IWIS3 (ICIS version) in your computer. This is version 5.4 of ICIS. Press the OK button to start the installation. $\r$\n$\r$\nYou can press the Cancel button if you do not want to install this software." IDOK true IDCANCEL false
      ${Break}
  ${EndSwitch}
  false:
    Abort
  true:
  ; Put Add/Remove Programs notification
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "DisplayName" "IWIS3 (ICIS v. 5.4)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "DisplayIcon" "$INSTDIR\Launcher.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "Publisher" "CIMMYT Int."
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "SupportInformation" "http://cropwiki.irri.org/icis/index.php/ICISWiki"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "ProductID" "5.4"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "DisplayVersion" "5.4"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "VersionMajor" "5"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "VersionMinor" "4"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "NoModify" "1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "NoRepair" "1"
FunctionEnd

Function SetCustom ;FunctionName defined with Page command
  ;Messagebox MB_OK "Custom input section"
  ;Display the Install Options dialog
  Push $R0
  InstallOptions::dialog $PLUGINSDIR\UserPassword.ini
  Pop $R0
FunctionEnd

Function ValidateCustom
  ReadINIStr $R0 "$PLUGINSDIR\UserPassword.ini" "Field 4" "State"
  StrCmp $R0 "" 0 CropOK
    ${Switch} $LANGUAGE
      ${Case} ${LANG_SPANISH}
        MessageBox MB_ICONEXCLAMATION|MB_OK "Favor de escribir la abreviatura del Cultivo"
        ${Break}
      ${Case} ${LANG_DANISH}
        MessageBox MB_ICONEXCLAMATION|MB_OK "Vær venlig at skrive forkortet Afgrødenavn"
        ${Break}
      ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
        MessageBox MB_ICONEXCLAMATION|MB_OK "Please enter the Crop abbreviation"
        ${Break}
    ${EndSwitch}
    Abort
  CropOK:

  ReadINIStr $R0 "$PLUGINSDIR\UserPassword.ini" "Field 5" "State"
  StrCmp $R0 "" 0 UserOK
    MessageBox MB_ICONEXCLAMATION|MB_OK "Please enter your User Name"
    ${Switch} $LANGUAGE
      ${Case} ${LANG_SPANISH}
        MessageBox MB_ICONEXCLAMATION|MB_OK "Favor de escribir el nombre del Usuario"
        ${Break}
      ${Case} ${LANG_DANISH}
        MessageBox MB_ICONEXCLAMATION|MB_OK "Vær venlig at skrive Brugernavn"
        ${Break}
      ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
        MessageBox MB_ICONEXCLAMATION|MB_OK "Please enter your User Name"
        ${Break}
    ${EndSwitch}
    Abort
  UserOK:

  ReadINIStr $R0 "$PLUGINSDIR\UserPassword.ini" "Field 6" "State"
  StrCmp $R0 "" 0 PassOK
    MessageBox MB_ICONEXCLAMATION|MB_OK "Please enter the password for User"
    ${Switch} $LANGUAGE
      ${Case} ${LANG_SPANISH}
        MessageBox MB_ICONEXCLAMATION|MB_OK "Favor de escribir la clave del Usuario"
        ${Break}
      ${Case} ${LANG_DANISH}
        MessageBox MB_ICONEXCLAMATION|MB_OK "Vær venlig at skrive brugerens kodeord"
        ${Break}
      ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
        MessageBox MB_ICONEXCLAMATION|MB_OK "Please enter the password for User"
        ${Break}
    ${EndSwitch}
    Abort
  PassOK:
FunctionEnd

Section "Central DBs in PC" InstDBs
  ${GetDrives} "CDROM" "FindDrivePath"
  ; Install DMS central database in users PC (not necessary inside CIMMYT)
  IfFileExists $CDdrive:\IWIS3-INSTALL-DMS-DATA.exe +2 0
     MessageBox MB_OK "Please insert CD in drive $CDdrive:"
  IfFileExists $CDdrive:\IWIS3-INSTALL-DMS-DATA.exe 0 +2
     ExecWait "$CDdrive:\IWIS3-INSTALL-DMS-DATA.exe"
  ; Install GMS central database in users PC (not necessary inside CIMMYT)
  IfFileExists $CDdrive:\IWIS3-INSTALL-GMS-DATA.exe +2 0
     MessageBox MB_OK "Please insert CD in drive $CDdrive:"
  IfFileExists $CDdrive:\IWIS3-INSTALL-GMS-DATA.exe 0 +2
     ExecWait "$CDdrive:\IWIS3-INSTALL-GMS-DATA.exe"
  ; Install DMS central database in users PC (not necessary inside CIMMYT)
  IfFileExists $CDdrive:\IWIS3-INSTALL-IMS-DATA.exe +2 0
     MessageBox MB_OK "Please insert CD in drive $CDdrive:"
  IfFileExists $CDdrive:\IWIS3-INSTALL-IMS-DATA.exe 0 +2
     ExecWait "$CDdrive:\IWIS3-INSTALL-IMS-DATA.exe"
SectionEnd

; Old program files and DLLs (necessary if first time)
Section "Old program files" InstPgmOld
  ;Messagebox MB_OK "Old program files section"
  ${GetDrives} "CDROM" "FindDrivePath"
  ;Messagebox MB_OK "CD Drive found was : $CDdrive:\"
  IfFileExists $CDdrive:\ICISProg.exe +2 0
     MessageBox MB_OK "Please insert CD in drive $CDdrive:"
  IfFileExists $CDdrive:\ICISProg.exe 0 +2
     ExecWait "$CDdrive:\ICISProg.exe"
SectionEnd

Section "ICIS documentation" InstDoc
  ;Messagebox MB_OK "ICIS Documentation section"
  ${GetDrives} "CDROM" "FindDrivePath"
  ;Messagebox MB_OK "CD Drive found was : $CDdrive:\"
  IfFileExists $CDdrive:\ICISDoc.exe +2 0
     MessageBox MB_OK "Please insert CD in drive $CDdrive:"
  IfFileExists $CDdrive:\ICISDoc.exe 0 +2
     ExecWait "$CDdrive:\ICISDoc.exe"
SectionEnd

Function FindDrivePath  ; FindDrivePath will return drive letter [e.g. D for D:\] in variable $CDdrive
   StrCpy $CDdrive $9 1
   Push $0
FunctionEnd

Section "Newest executables" InstNewExe
  ;Messagebox MB_OK "Newest executables"
  SETOUTPATH $INSTDIR\Exes
  File C:\ICIS5\Exes\GMSSrch.exe
  ;File C:\ICIS5\Exes\icis_validate.exe
  File C:\ICIS5\Exes\InTrack.exe
  File C:\ICIS5\Exes\Browse.exe
  File C:\ICIS5\Exes\ICIS32.DLL
  File C:\ICIS5\Exes\ICIS-RTV.MDB
  File C:\ICIS5\Exes\SetGen.exe
  File C:\ICIS5\Exes\IcisWorkbook.xla
  File C:\ICIS5\Exes\GMSInput.exe
  File C:\ICIS5\Exes\ICISForms.exe
  File C:\ICIS5\Exes\Launcher.exe
  File C:\ICIS5\Exes\Launcher.txt
  SETOUTPATH $INSTDIR\Exes\icis_diag_resources
  File "C:\ICIS5\Exes\icis_diag_resources\Central DMS.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\Central DMS_PATCH.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\Central GMS.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\Central GMS_PATCH.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\CREDITS.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\dms.sql"
  File "C:\ICIS5\Exes\icis_diag_resources\dmstest.sql"
  File "C:\ICIS5\Exes\icis_diag_resources\gms.sql"
  File "C:\ICIS5\Exes\icis_diag_resources\gmstest.sql"
  File "C:\ICIS5\Exes\icis_diag_resources\ICIS Installation Diagnostic Tool - RESULTS.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\icis-diag.chm"
  File "C:\ICIS5\Exes\icis_diag_resources\ICIS_DIAG.INI"
  File "C:\ICIS5\Exes\icis_diag_resources\LICENSE.TXT"
  File "C:\ICIS5\Exes\icis_diag_resources\Local DMS.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\Local DMS_PATCH.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\Local GMS.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\Local GMS_PATCH.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\README.txt"
  File "C:\ICIS5\Exes\icis_diag_resources\results.txt"
  SETOUTPATH $INSTDIR\Exes\icis_diag_resources\images
  File "C:\ICIS5\Exes\icis_diag_resources\images\check.jpg"
  File "C:\ICIS5\Exes\icis_diag_resources\images\CRIL Logo_4.jpg"
  File "C:\ICIS5\Exes\icis_diag_resources\images\icis.jpg"
  File "C:\ICIS5\Exes\icis_diag_resources\images\icis_background.JPG"
  File "C:\ICIS5\Exes\icis_diag_resources\images\icis_diag.jpg"
  File "C:\ICIS5\Exes\icis_diag_resources\images\icis_validate.jpg"
  File "C:\ICIS5\Exes\icis_diag_resources\images\irri_logo.gif"
  File "C:\ICIS5\Exes\icis_diag_resources\images\Presentation1.jpg"
  File "C:\ICIS5\Exes\icis_diag_resources\images\Presentation1.ppt"
  File "C:\ICIS5\Exes\icis_diag_resources\images\Thumbs.db"
  SETOUTPATH $INSTDIR\Exes
  File "C:\ICIS5\Exes\Installation Diagnostic Tool.exe"
  SETOUTPATH $INSTDIR\Exes\dmsfiles\themes
  File "C:\ICIS5\Setup\WISE\themes\wheat.bmp"
  SETOUTPATH $INSTDIR\Exes\images
  File "C:\ICIS5\EXES\images\defwallpaper.bmp"
  File "C:\ICIS5\EXES\images\deflogo.bmp"
SectionEnd

Section "-Default section - always executed (because it begins with -)"
  ;Messagebox MB_OK "Default section"
  ReadINIStr $Crop "$PLUGINSDIR\UserPassword.ini" "Field 4" "State"
  ReadINIStr $UserName "$PLUGINSDIR\UserPassword.ini" "Field 5" "State"
  ReadINIStr $Password "$PLUGINSDIR\UserPassword.ini" "Field 6" "State"
  ;Messagebox MB_OK "Crop is : $Crop"
  ;Messagebox MB_OK "Username is : $UserName"
  ;Messagebox MB_OK "Password is : $Password"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "Crop" "$Crop"
  ; Create necessary directories for files to be installed
  CreateDirectory $INSTDIR\Exes
  CreateDirectory $INSTDIR\Database
  CreateDirectory $INSTDIR\Database\$Crop
  CreateDirectory $INSTDIR\Database\$Crop\Central
  CreateDirectory $INSTDIR\Database\$Crop\Local
  File /oname=$INSTDIR\Database\$Crop\Local\$Crop-WGB-RTV.mdb C:\ICIS5\Setup\WISE\IWIS3-WGB-RTV.mdb
  File /oname=$INSTDIR\Exes\$Crop.ini C:\ICIS5\Setup\WISE\ICIS.ini
  ; Assign a mapped drive from \\PM2000\ICIS5 automatically and put that in ODBC sources
  ; If it couldn't be assigned, then C:\ICIS5\... will be used
  StrCpy $MappedDrive "C:\ICIS5"
  ; Check first if it was already assigned to some network drive, then recover that
  ${GetDrives} "NET" "RecoverMappedDrive"
  ; It wasn't found, so try to add it, recovering which drive letter was assigned
  ${If} $MappedDrive == "C:\ICIS5"
    ${MyArray->Init}
    StrCpy $R1 0
    ${GetDrives} "NET" "SaveMappedDrives"
    ExecWait '"net" "use" "*" "\\PM2000\ICIS5" "/persistent:yes"'
    StrCpy $R1 0
    ${GetDrives} "NET" "GetMappedDriveLetter"
    ${MyArray->Delete}
  ${EndIf}

  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "Central GMS" "DSN" "$Crop-CENTRAL-GMS"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "Local GMS" "DSN" "$Crop-LOCAL-GMS"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "Local GMS" "UID" "$UserName"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "Local GMS" "PWD" "$Password"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "Local GMS" "DSN" "$Crop-LOCAL-GMS"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "Central DMS" "DSN" "$Crop-CENTRAL-DMS"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "Local DMS" "DSN" "$Crop-LOCAL-DMS"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "IMS" "DSN" "$Crop-WGB-IMS"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "IMS" "UID" "$UserName"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "IMS" "PWD" "$Password"

  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "BROWSE" "LastDir" "$INSTDIR\Database"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "CONFIGURATION" "LastDir" "$INSTDIR\Database"
  WriteINIStr "$INSTDIR\Exes\$Crop.INI"  "WORKBOOK" "LastDir" "$INSTDIR\Database"

  ; Configure ODBC data source GMS Central
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-CENTRAL-GMS" "Microsoft Access Driver (*.mdb)"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "DBQ" "$MappedDrive\Database\$Crop\Central\$Crop-GMS.mdb"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "Driver" "$SYSDIR\odbcjt32.dll"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "DriverId" "25"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "FIL" "MS Access;"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "SafeTransactions" "0"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "ImplicitCommitSync" ""
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "MaxBufferSize" "4096"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "PageTimeout" "5"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "Threads" "3"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "UserCommitSync" "Yes"
  ; Configure ODBC data source DMS Central
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-CENTRAL-DMS" "Microsoft Access Driver (*.mdb)"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "DBQ" "$MappedDrive\Database\$Crop\Central\$Crop-DMS.mdb"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "Driver" "$SYSDIR\odbcjt32.dll"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "DriverId" "25"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "FIL" "MS Access;"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "SafeTransactions" "0"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "ImplicitCommitSync" ""
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "MaxBufferSize" "4096"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "PageTimeout" "5"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "Threads" "3"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "UserCommitSync" "Yes"
  ; Configure ODBC data source GMS Local
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-LOCAL-GMS" "Microsoft Access Driver (*.mdb)"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "DBQ" "$INSTDIR\Database\$Crop\Local\$Crop-LOCAL-GMS.mdb"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "Driver" "$SYSDIR\odbcjt32.dll"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "DriverId" "25"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "FIL" "MS Access;"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "SafeTransactions" "0"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "ImplicitCommitSync" ""
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "MaxBufferSize" "4096"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "PageTimeout" "5"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "Threads" "3"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "UserCommitSync" "Yes"
  ; Configure ODBC data source DMS Local
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-LOCAL-DMS" "Microsoft Access Driver (*.mdb)"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "DBQ" "$INSTDIR\Database\$Crop\Local\$Crop-LOCAL-DMS.mdb"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "Driver" "$SYSDIR\odbcjt32.dll"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "DriverId" "25"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "FIL" "MS Access;"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "SafeTransactions" "0"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "ImplicitCommitSync" ""
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "MaxBufferSize" "4096"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "PageTimeout" "5"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "Threads" "3"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "UserCommitSync" "Yes"
  ; Configure ODBC data source IMS (Inventory Management System)
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-WGB-IMS" "Microsoft Access Driver (*.mdb)"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "DBQ" "$MappedDrive\Database\$Crop\Local\$Crop-WGB-IMS.mdb"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "Driver" "$SYSDIR\odbcjt32.dll"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "DriverId" "25"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "FIL" "MS Access;"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "SafeTransactions" "0"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "ImplicitCommitSync" ""
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "MaxBufferSize" "4096"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "PageTimeout" "5"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "Threads" "3"
  WriteRegStr HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "UserCommitSync" "Yes"

  Delete $INSTDIR\Database\$Crop\README.TXT
  ClearErrors
  FileOpen $0 $INSTDIR\Database\$Crop\README.TXT w
  IfErrors done
  FileWrite $0 "$\r$\n"
  FileWrite $0 "Copy your Local GMS database to here: $\r$\n"
  FileWrite $0 "$INSTDIR\Database\$Crop\Local\$Crop-LOCAL-GMS.mdb$\r$\n"
  FileWrite $0 "$\r$\n"
  FileWrite $0 "Copy your Local DMS database to here: $\r$\n"
  FileWrite $0 "$INSTDIR\Database\$Crop\Local\$Crop-LOCAL-DMS.mdb$\r$\n"
  FileWrite $0 "$\r$\n"
  FileWrite $0 "Copy your Central GMS database to here: $\r$\n"
  FileWrite $0 "$INSTDIR\Database\$Crop\Central\$Crop-CENTRAL-GMS.mdb$\r$\n"
  FileWrite $0 "$\r$\n"
  FileWrite $0 "Copy your Central DMS database to here: $\r$\n"
  FileWrite $0 "$INSTDIR\Database\$Crop\Central\$Crop-CENTRAL-DMS.mdb$\r$\n"
  FileWrite $0 "$\r$\n"
  FileWrite $0 "Copy your Local IMS database to here: $\r$\n"
  FileWrite $0 "$INSTDIR\Database\$Crop\Local\$Crop-WGB-IMS.mdb$\r$\n"
  FileWrite $0 "$\r$\n"
  FileWrite $0 "To use the database from the ICIS Launcher, make sure to first click on 'Change INI' and read it in from $INSTDIR\Exes\$Crop.ini"
  FileClose $0
  done:
  CreateShortcut "$DESKTOP\ICIS 5.LNK" $INSTDIR\Exes\Launcher.exe
  CreateShortcut "$DESKTOP\ODBC Data Sources.LNK" $SYSDIR\Odbcad32.exe
  ;Store installation folder
  WriteRegStr HKCU "Software\IWIS3" "" $INSTDIR
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Function RecoverMappedDrive
  IfFileExists $9EXES\ICIS32.DLL 0 +3
     StrCpy $MappedDrive $9 1
     StrCpy $MappedDrive "$MappedDrive:"
  Push $0
FunctionEnd

Function SaveMappedDrives
  ${MyArray->Write} $R1 $9
  ;Messagebox MB_OK "Reading MyArray[$R1] = $9"
  IntOp $R1 $R1 + 1
  Push $0
FunctionEnd

Function GetMappedDriveLetter
  ${MyArray->Read} $R2 $R1
  IntOp $R1 $R1 + 1
  ${If} $MappedDrive == "C:\ICIS5"
     StrCmp $9 $R2 +3 0
        StrCpy $MappedDrive $9 1
        StrCpy $MappedDrive "$MappedDrive:"
  ${EndIf}
  Messagebox MB_OK "Mapped drive is $MappedDrive"
  Push $0
FunctionEnd

Section "Local databases" InstLocalDB
  Messagebox MB_OK "Local databases section"
  IfFileExists $INSTDIR\Database\$Crop\Local\$Crop-LOCAL-GMS.mdb 0 NoLocal
     ${Switch} $LANGUAGE
       ${Case} ${LANG_SPANISH}
         MessageBox MB_YESNO "La base de datos $INSTDIR\Database\$Crop\Local\$Crop-LOCAL-GMS.mdb ya existe. Quieres resguardar tus bases locales en lugar de sobreescribir?" IDYES KeepFile IDNO NoLocal
          ${Break}
       ${Case} ${LANG_DANISH}
         MessageBox MB_YESNO "Databasen $INSTDIR\Database\$Crop\Local\$Crop-LOCAL-GMS.mdb findes allerede. Vil du beholde de lokale databaser i stedet for at overskrive?" IDYES KeepFile IDNO NoLocal
         ${Break}
       ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
         MessageBox MB_YESNO "The database $INSTDIR\Database\$Crop\Local\$Crop-LOCAL-GMS.mdb already exists. Do you want to keep your local databases instead of overwriting?" IDYES KeepFile IDNO NoLocal
         ${Break}
     ${EndSwitch}
  NoLocal:
  File /oname=$INSTDIR\Database\$Crop\Local\$Crop-LOCAL-DMS.mdb C:\ICIS5\Setup\WISE\DMS-Local.mdb
  File /oname=$INSTDIR\Database\$Crop\Local\$Crop-LOCAL-GMS.mdb C:\ICIS5\Setup\WISE\GMS-Local.mdb
  KeepFile:
  ${Switch} $LANGUAGE
    ${Case} ${LANG_SPANISH}
      MessageBox MB_YESNO "Quieres sobreescribir el Usuario en las bases locales?" IDYES NewUser IDNO KeepUser
      ${Break}
    ${Case} ${LANG_DANISH}
      MessageBox MB_YESNO "Vil du overskrive Brugernavn i de lokale databaser?" IDYES NewUser IDNO KeepUser
      ${Break}
    ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
      MessageBox MB_YESNO "Do you want to overwrite the User in the local databases?" IDYES NewUser IDNO KeepUser
      ${Break}
  ${EndSwitch}
  ; Write the UserName and the password to the USERS file of local GMS
  ; Write the INSTL file with correct INSTLN parameters
  NewUser:
  SETOUTPATH C:\ICIS5\Exes
  File C:\ICIS5\Setup\IODBC\IODBC.exe

  Delete $INSTDIR\Exes\Input.TXT
  ClearErrors
  FileOpen $0 $INSTDIR\Exes\Input.TXT w
  IfErrors done2
  FileWrite $0 "SELECT UPSWD,ADATE,USERID,INSTALID From USERS Where UNAME = '$UserName'$\r$\n"
  FileWrite $0 "GO$\r$\n"
  FileWrite $0 "EXIT$\r$\n"
  FileClose $0
  ExecWait '"$INSTDIR\Exes\IODBC.EXE" "/S$Crop-CENTRAL-GMS" "/iInput.txt" "/oOutput.txt"'
  done2:
  ; We need to read the Output.txt file to find out what are the parameters to pass to the local GMS table
  ${LineRead} $INSTDIR\Exes\Output.txt 6 $R1
  StrCpy $Upswd $R1 8 1
  StrCpy $Adate $R1 10 13
  StrCpy $Userid $R1 6 25
  StrCpy $Instalid $R1 6 33
  ; Trim superfluous spaces from the strings
  ${WordReplace} $Upswd " " "" "{}" $Upswd
  ${WordReplace} $Adate " " "" "{}" $Adate
  ${WordReplace} $Userid " " "" "{}" $Userid
  ${WordReplace} $Instalid " " "" "{}" $Instalid
  Messagebox MB_OK "User password from central GMS is : $Upswd."
  Messagebox MB_OK "ADate from central GMS is : $Adate."
  Messagebox MB_OK "Userid from central GMS is : $Userid."
  Messagebox MB_OK "Instalid from central GMS is : $Instalid."

  ; Read the USERID from the local database so as to be able to overwrite
  ; I assume there is only one user here, but if not perhaps we will get a good one in line 6
  Delete $INSTDIR\Exes\Input4.TXT
  ClearErrors
  FileOpen $0 $INSTDIR\Exes\Input4.TXT w
  IfErrors done
  FileWrite $0 "SELECT USERID From USERS$\r$\n"
  FileWrite $0 "GO$\r$\n"
  FileWrite $0 "EXIT$\r$\n"
  FileClose $0
  ExecWait '"$INSTDIR\Exes\IODBC.EXE" "/S$Crop-LOCAL-GMS" "/iInput4.txt" "/oOutput4.txt"'
  done:
  ; We need to read the Output4.txt file to find USERID from the local GMS table
  ${LineRead} $INSTDIR\Exes\Output4.txt 6 $R1
  StrCpy $LocalUserid $R1 18 1
  ; Trim superfluous spaces from the string
  ${WordReplace} $LocalUserid " " "" "{}" $LocalUserid
  Messagebox MB_OK "Userid from local GMS is : $LocalUserid."

  FileOpen $0 $INSTDIR\Exes\Cmd.txt w
  FileWrite $0 "UPDATE USERS Set UPSWD = '$Upswd' Where USERID = $LocalUserid$\r$\n"
  FileWrite $0 "GO $\r$\n"
  FileWrite $0 "UPDATE USERS Set ADATE = $Adate Where USERID = $LocalUserid$\r$\n"
  FileWrite $0 "GO $\r$\n"
  FileWrite $0 "UPDATE USERS Set INSTALID = $Instalid Where USERID = $LocalUserid$\r$\n"
  FileWrite $0 "GO $\r$\n"
  FileWrite $0 "UPDATE USERS Set UNAME = '$UserName' Where USERID = $LocalUserid$\r$\n"
  FileWrite $0 "GO $\r$\n"
  FileWrite $0 "UPDATE USERS Set USERID = $Userid Where USERID = $LocalUserid$\r$\n"
  FileWrite $0 "GO $\r$\n"
  FileWrite $0 "UPDATE INSTLN Set UDATE = $Adate Where ADMIN = $LocalUserid$\r$\n"
  FileWrite $0 "GO $\r$\n"
  FileWrite $0 "UPDATE INSTLN Set INSTALID = $Instalid Where ADMIN = $LocalUserid$\r$\n"
  FileWrite $0 "GO $\r$\n"
  FileWrite $0 "UPDATE INSTLN Set ADMIN = $Userid Where ADMIN = $LocalUserid$\r$\n"
  FileWrite $0 "GO $\r$\n"
  FileWrite $0 "EXIT $\r$\n"
  FileClose $0
  ExecWait '"$INSTDIR\Exes\IODBC.EXE" "/S$Crop-LOCAL-GMS" "/iCmd.txt" "/oCmdOut.txt"'
  ExecWait '"$INSTDIR\Exes\IODBC.EXE" "/S$Crop-LOCAL-DMS" "/iCmd.txt" "/oCmdOut3.txt"'
  ; Now set the IDESC description field based on the Central GMS database value
  Delete $INSTDIR\Exes\Input2.TXT
  ClearErrors
  FileOpen $0 $INSTDIR\Exes\Input2.TXT w
  IfErrors done3
  FileWrite $0 "SELECT IDESC From INSTLN Where ADMIN = $Userid$\r$\n"
  FileWrite $0 "GO$\r$\n"
  FileWrite $0 "EXIT$\r$\n"
  FileClose $0
  ExecWait '"$INSTDIR\Exes\IODBC.EXE" "/S$Crop-CENTRAL-GMS" "/iInput2.txt" "/oOutput2.txt"'
  done3:
  ; We need to read the Output2.txt file to find out what are the parameters to pass to the local GMS table
  ${LineRead} $INSTDIR\Exes\Output2.txt 9 $Idesc
  ; Trim superfluous spaces from the string
  ${WordReplace} $Idesc " " "" "{}" $Idesc
  ClearErrors
  FileOpen $0 $INSTDIR\Exes\Cmd2.txt w
  IfErrors done4
  FileWrite $0 "UPDATE INSTLN Set IDESC = '$Idesc' Where INSTALID = $Instalid$\r$\n"
  FileWrite $0 "GO $\r$\n"
  FileWrite $0 "EXIT $\r$\n"
  FileClose $0
  ExecWait '"$INSTDIR\Exes\IODBC.EXE" "/S$Crop-LOCAL-GMS" "/iCmd2.txt" "/oCmdOut2.txt"'
  done4:
  ; Cleanup before exiting the IODBC executable, we don't need these files anymore
  ;Delete $INSTDIR\Exes\Input.txt
  ;Delete $INSTDIR\Exes\Output.txt
  ;Delete $INSTDIR\Exes\Cmd.txt
  ;Delete $INSTDIR\Exes\CmdOut.txt
  ;Delete $INSTDIR\Exes\Cmd2.txt
  ;Delete $INSTDIR\Exes\CmdOut2.txt
  ;Delete $INSTDIR\Exes\CmdOut3.txt
  ;Delete $INSTDIR\Exes\Input4.txt
  ;Delete $INSTDIR\Exes\Output4.txt
  ;Delete $INSTDIR\Exes\IODBC.EXE
  KeepUser:
SectionEnd

Function .onInstSuccess
  ${Switch} $LANGUAGE
    ${Case} ${LANG_SPANISH}
      MessageBox MB_OK "IWIS3 se instaló exitosamente en su PC!"
      ${Break}
    ${Case} ${LANG_DANISH}
      MessageBox MB_OK "IWIS3 blev installeret OK i din PC!"
      ${Break}
    ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
      MessageBox MB_OK "IWIS3 was successfully installed in your PC!"
      ${Break}
  ${EndSwitch}
  ${Switch} $LANGUAGE
    ${Case} ${LANG_SPANISH}
      MessageBox MB_YESNO "Quieres ejecutar el programa ahora?" IDYES RunProg IDNO NoRun
      ${Break}
    ${Case} ${LANG_DANISH}
      MessageBox MB_YESNO "Vil du starte programmet nu?" IDYES RunProg IDNO NoRun
      ${Break}
    ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
      MessageBox MB_YESNO "Do you want to run the program now?" IDYES RunProg IDNO NoRun
      ${Break}
  ${EndSwitch}
  RunProg:
    ${Switch} $LANGUAGE
      ${Case} ${LANG_SPANISH}
        MessageBox MB_OK "No olvides cambiar INI para $Crop.INI!"
        ${Break}
      ${Case} ${LANG_DANISH}
        MessageBox MB_OK "Husk at indlæse INI filen $Crop.INI!"
        ${Break}
      ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
        MessageBox MB_OK "Don't forget to read in the INI file $Crop.INI!"
        ${Break}
    ${EndSwitch}
    Exec "$INSTDIR\Exes\Launcher.exe"
  NoRun:
FunctionEnd

Section un.Install
  ${Switch} $LANGUAGE
    ${Case} ${LANG_SPANISH}
      MessageBox MB_OKCANCEL "Este programa desinstalará el programa IWIS3 v.5.4 de su computadora. Seleccione ´Aceptar´ para empezar la desinstalación. Seleccione ´Cancelar´ si no quieres desinstalar el programa." IDOK true2 IDCANCEL false2
      ${Break}
    ${Case} ${LANG_DANISH}
      MessageBox MB_OKCANCEL "Dette program vil afinstallere IWIS3 v.5.4 fra din computer. Klik ´OK´ for at starte afinstallationen. Du kan klikke ´Fortryd´ hvis du ikke vil afinstallere programmet." IDOK true2 IDCANCEL false2
      ${Break}
    ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
      MessageBox MB_OKCANCEL "This program will uninstall IWIS3 v.5.4 from your computer. Press the OK button to start the deinstallation. You can press the Cancel button if you do not want to uninstall this software." IDOK true2 IDCANCEL false2
      ${Break}
  ${EndSwitch}
  false2:
    Abort
  true2:
  ; Delete MySelf!! Fortunately it works as explained in NSIS documentation
  Delete $INSTDIR\Uninstall.exe
  Delete "$INSTDIR\Database\Template\CentralQueries.mdb"
  Delete "$INSTDIR\Database\Template\Central\ConvertCentralToV4.mdb"
  Delete "$INSTDIR\Database\Template\Central\DMS-Central.mdb"
  Delete "$INSTDIR\Database\Template\Central\DMS-Central.zip"
  Delete "$INSTDIR\Database\Template\Central\GMS-Central.mdb"
  Delete "$INSTDIR\Database\Template\Central\ICIS ConvertCentralToV4_2.mdb"
  Delete "$INSTDIR\Database\Template\Central\ICIS ConvertCentralToV5.mdb"
  Delete "$INSTDIR\Database\Template\Central\ICIS ConvertCentralToV5.zip"
  Delete "$INSTDIR\Database\Template\Central\ICIS.ini"
  Delete "$INSTDIR\Database\Template\Central\ICIS-TMM.mdb"
  Delete "$INSTDIR\Database\Template\Central\ICIS-TMS.mdb"
  Delete "$INSTDIR\Database\Template\Local\ConvertLocalToV4.mdb"
  Delete "$INSTDIR\Database\Template\Local\DMS-Local.mdb"
  Delete "$INSTDIR\Database\Template\Local\DMS-Local.zip"
  Delete "$INSTDIR\Database\Template\Local\GMS-Local.mdb"
  Delete "$INSTDIR\Database\Template\Local\GMS-Local.zip"
  Delete "$INSTDIR\Database\Template\Local\ICIS-RTV.zip"
  Delete "$INSTDIR\Database\Template\Local\ICIS ConvertLocalToV4_2.mdb"
  Delete "$INSTDIR\Database\Template\Local\ICIS ConvertLocalToV5.mdb"
  Delete "$INSTDIR\Database\Template\Local\ICIS ConvertLocalToV5.zip"
  Delete "$INSTDIR\Database\Template\Local\ICIS-Local.mdb"
  Delete "$INSTDIR\Database\Template\Local\ICIS-Local.zip"
  Delete "$INSTDIR\Database\Template\Local\ICIS-RTV.ldb"
  Delete "$INSTDIR\Database\Template\Local\ICIS-RTV.mdb"
  Delete "$INSTDIR\Database\Template\Local\IMS-LOCAL.mdb"
  Delete "$INSTDIR\Database\Template\Local\MySQL\icislocal.sql"
  Delete "$INSTDIR\Database\Template\Local\Postgres\Create_IcisLocal_PostgreSQL_v5.txt"
  Delete "$INSTDIR\Database\Template\Local\Postgres\gems_postgres_template.txt"
  Delete "$INSTDIR\Database\Template\Query to COnvert\ConvertToV4.mdb"
  Delete "$INSTDIR\Database\Template\Query to COnvert\VEFFECT.mdb"
  Delete "$INSTDIR\Database\Template\Query to Upload\DMS-CentralQry.mdb"
  Delete "$INSTDIR\Database\Template\Query to Upload\DMS-LocalQry.mdb"
  Delete "$INSTDIR\Database\Template\Upload Tool\ICIS_uplload.sql"
  Delete "$INSTDIR\Document\TDM\ICIS_doc_template.dot"
  Delete "$INSTDIR\Document\TDM\ICIS_I_A.doc"
  Delete "$INSTDIR\Document\TDM\I Overview\A Introduction\ICIS_I_A.DOC"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course.zip"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\1 Launcher\ICIS_II_A_1.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\11 ICIS Bioinformatic Workbench\Loc_GEMS_appendices.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\11 ICIS Bioinformatic Workbench\Loc_GEMS_users_manual.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\2 GMS Search\ICIS_II_A_2.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\3 GMS Browse\ICIS_II_A_3.DOC"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\4 SET GENERATION\ICIS_II_A_4b.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\4 SET GENERATION\ICIS_II_A_4.doc"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\4 SET GENERATION\~IS_II_A_4.doc"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\5 GMS Input\ICIS_II_A_5.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\6 IRRI Breeding applications\ICIS_II_C_6.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\7 ICIS Workbook\ICIS_II_A_7 (under construction).doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\7 ICIS Workbook\ICIS_II_A_7.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\7 ICIS Workbook\ICIS07L_DMS_Overview (from ICIS4).DOC"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\7 ICIS Workbook\Menu Guide.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\7 ICIS Workbook\Screenshots1.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\7 ICIS Workbook\Screenshots2.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\8 DMS Retriever\ICIS_II_C_8.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\9 ICIS Inventory Tracking\ICIS_II_A_9a.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\9 ICIS Inventory Tracking\ICIS_II_A_9b.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\B. Web Interface\ICIS_II_D_Web_Interface.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\Plant Breeding Course.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\Setting up the Training.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\01 01&2_Introduction\ICIS-BreedingTools.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\01 01&2_Introduction\ICISIntro.DOC"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\01 01&2_Introduction\ICIS-Introduction.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\01 01&2_Introduction\IRIS_MetaAnalysis.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\01 01&2_Introduction\IRIS-Breeding.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\01 01&2_Introduction\International Crop Information System 2005.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\02 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\HBand F1.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\02 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\trainingforF1.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\02 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\Training.ini"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\02 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\02 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\Training.zip"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\03 06_Reserving of Seed Stock for HB List\MANAGING SEED STOCKS - RESERVATION.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\03 06_Reserving of Seed Stock for HB List\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\04 07_Advancing Lines with interactive tools\Adding Checks to a Pedigree Nursery.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\04 07_Advancing Lines with interactive tools\Managing Pedigree Nursery Information with IRIS.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\04 07_Advancing Lines with interactive tools\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\05 08_09 Using Workbook to manage evaluation data\Appendix F.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\05 08_09 Using Workbook to manage evaluation data\DMS Workbook.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\05 08_09 Using Workbook to manage evaluation data\F4_template.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\05 08_09 Using Workbook to manage evaluation data\MANAGING NURSERY TRIALS THROUGH IRIS.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\05 08_09 Using Workbook to manage evaluation data\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\05 08_09 Using Workbook to manage evaluation data\U03WSHB_data.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\05 08_09 Using Workbook to manage evaluation data\WORKBOOK TEMPLATES.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\06 10_Advancing Lines with batch processing tools\Advancing of Pedigree Nursery by Batch Processing.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\06 10_Advancing Lines with batch processing tools\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\06 10_Advancing Lines with batch processing tools\Training-result_of-08.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\06 10_Advancing Lines with batch processing tools\U05WSF4F.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\06 10_Advancing Lines with batch processing tools\UWS02-06 selections.xls"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\06 10_Advancing Lines with batch processing tools\Training_.mdb"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\07 11_Depositing of Seed Stock  for F5 List - Interactive\MANAGING SEED STOCKS - DEPOSIT.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\07 11_Depositing of Seed Stock  for F5 List - Interactive\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\08 12_Replicated Yield Trials\alpha_layout.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\08 12_Replicated Yield Trials\Amount Harvested.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\08 12_Replicated Yield Trials\Loaded-URYT-Template.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\08 12_Replicated Yield Trials\RYTExercise.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\08 12_Replicated Yield Trials\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\08 12_Replicated Yield Trials\URYT-Template.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\09 13_Deposting of Seed Stock for RYT List - Batch\Deposting of Seed Stock for RYT List - Batch.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\09 13_Deposting of Seed Stock for RYT List - Batch\Training_old_02092005.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\09 13_Deposting of Seed Stock for RYT List - Batch\Training_result_of_11.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\09 13_Deposting of Seed Stock for RYT List - Batch\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\ICIS-BreedingTools.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\ICISIntro.DOC"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\ICIS-Introduction.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\IRIS_MetaAnalysis.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\IRIS-Breeding.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Copy of TRAINING-RTV.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Data Queries and Report with DMS Retriever.doc"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Data Queries and Report with ICIS Retriever.doc"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\DMSRetriever.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Training_bak.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Training-DMS.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Training-RTV.ini"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\TRAINING-RTV.mdb"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\DMSRetrieverv5_3_0.ppt"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\11 15_Entering historical pedigrees into IRIS\Entering Historical Pedigrees.Doc"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\11 15_Entering historical pedigrees into IRIS\Entering Historical Pedigrees.txt"
  ;
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\13 17_Importing Nursery Lists\Importing Nursery List.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\13 17_Importing Nursery Lists\UDS03-07 F5.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\14 18_Using Browse for Pedigree Management\MANAGING GERMPLASM RECORDS.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\2 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\HBand F1.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\2 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\trainingforF1.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\2 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\Training.ini"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\2 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\3 06_Reserving of Seed Stock for HB List\MANAGING SEED STOCKS - RESERVATION.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\3 06_Reserving of Seed Stock for HB List\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\4 07_Advancing Lines with interactive tools\Adding Checks to a Pedigree Nursery.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\4 07_Advancing Lines with interactive tools\Managing Pedigree Nursery Information with IRIS.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\4 07_Advancing Lines with interactive tools\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\5 08_09 Using Workbook to manage evaluation data\Appendix F.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\5 08_09 Using Workbook to manage evaluation data\DMS Workbook.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\5 08_09 Using Workbook to manage evaluation data\F4_template.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\5 08_09 Using Workbook to manage evaluation data\MANAGING NURSERY TRIALS THROUGH IRIS.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\5 08_09 Using Workbook to manage evaluation data\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\5 08_09 Using Workbook to manage evaluation data\U03WSHB_data.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\5 08_09 Using Workbook to manage evaluation data\WORKBOOK TEMPLATES.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\6 10_Advancing Lines with batch processing tools\Advancing of Pedigree Nursery by Batch Processing.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\6 10_Advancing Lines with batch processing tools\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\6 10_Advancing Lines with batch processing tools\Training-result_of-08.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\6 10_Advancing Lines with batch processing tools\UWS02-06 selections.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\7 11_Depositing of Seed Stock  for F5 List - Interactive\MANAGING SEED STOCKS - DEPOSIT.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\7 11_Depositing of Seed Stock  for F5 List - Interactive\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\7 11_Depositing of Seed Stock\MANAGING SEED STOCKS - DEPOSIT.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\7 11_Depositing of Seed Stock\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\8 12_Replicated Yield Trials\alpha_layout.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\8 12_Replicated Yield Trials\Amount Harvested.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\8 12_Replicated Yield Trials\Loaded-URYT-Template.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\8 12_Replicated Yield Trials\RYTExercise.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\8 12_Replicated Yield Trials\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\8 12_Replicated Yield Trials\URYT-Template.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\9 13_Deposting of Seed Stock for RYT List - Batch\Deposting of Seed Stock for RYT List - Batch.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\9 13_Deposting of Seed Stock for RYT List - Batch\Training_old_02092005.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\9 13_Deposting of Seed Stock for RYT List - Batch\Training_result_of_11.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\9 13_Deposting of Seed Stock for RYT List - Batch\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\ICIS-BreedingTools.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\ICISIntro.DOC"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\ICIS-Introduction.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\IRIS_MetaAnalysis.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\IRIS-Breeding.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Copy of TRAINING-RTV.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Data Queries and Report with DMS Retriever.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\DMSRetriever.ppt"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Training_bak.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Training-DMS.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Training.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\Training-RTV.ini"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\TRAINING-RTV.mdb"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\11 15_Entering historical pedigrees into IRIS\Entering Historical Pedigrees.Doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\13 17_Importing Nursery Lists\Importing Nursery List.doc"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\13 17_Importing Nursery Lists\UDS03-07 F5.xls"
  Delete "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\14 18_Using Browse for Pedigree Management\MANAGING GERMPLASM RECORDS.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\1 Users and Access\ICIS_III_A_1.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10.htm"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\People and Institute.wiki"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10_files\filelist.xml"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10_files\header.htm"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\GMS_StructureWiki b.txt"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\ICIS02G_GMS_Overview.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\ICIS03K_GMS_Structure.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\ICIS03K_GMS.wki"
  ;
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\GMS.wki"
  ;
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\Temp.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\3 List Management\List Management.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\3 List Management\LMS.wki"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\DMS Data Model.jpg"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\DMS.wiki.txt"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\ICIS_III_A_4.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\Table4_3_1.bmp"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\Table4_3_1.JPG"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\TMD DMS Observation Units.bmp"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\TMD DMS Observation Units.JPG"
  ;
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\LoadingIsozyme.wki"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\Thumbs.db"
  ;
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\5 Inventory Management System\ICIS_III_A_5.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\5 Inventory Management System\IMS.wki"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\6 Gene Management System\GEMS.wki"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\6 Gene Management System\ICIS18L_GEMS.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\8 Location Management System\LDMS Logical Structure.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\8 Location Management System\LDMS Use Case Model.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\9 Bibliographic References\ICIS_III_A_9.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\FundamentalDifferences_MOBY_LSID.pdf"
  Delete "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\LSID_Compliance_Implications.pdf"
  Delete "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\LSID_Compliance_Implications.rtf"
  Delete "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\WhyLSID.pdf"
  Delete "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\WhyMOBY.pdf"
  Delete "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\2 Germplasm Development and Maintenance Methods\ICIS_III_B_2a.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\2 Germplasm Development and Maintenance Methods\ICIS_III_B_2b.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\3 DMS Properties, Traits and Scales\ICIS_III_B_3.DOC"
  Delete "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\3 DMS Properties, Traits and Scales\ICIS-Ontology.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\1 ICIS Application and Database Installation\ICIS_III_C_1.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\2 Setting up a GMS Database\ICIS_III_C_2.doc"
  ;
  Delete "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\2 Setting up a GMS Database\~IS_III_C_2.doc"
  ;
  Delete "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\3 Setting up a DMS Database\ICIS_III_C_3.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\4 Setting up an IMS Database\ICIS_III_C_4_.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up ICIS5 web application\ICIS_III_C_7_linux.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up ICIS5 web application\ICIS_III_C_7_windows.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up ICIS5 web application\ICIS_III_C_7.doc"
  Delete "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up the Web Interface\ICIS_III_C_7.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\1 DLL Architecture\Dll Architecture.wiki"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\1 DLL Architecture\ICIS_IV_A_1.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\10 Integration of Web Services\Document Scrap 'Graham...'.shs"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\10 Integration of Web Services\ICIS 5-WebServices.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\2 ICIS Data Structures\ICIS Data Structures.wiki"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\2 ICIS Data Structures\ICIS_IV_A_2.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\3 DLL Functions for Access Control\ICIS_IV_A_3.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\4 GMS DLL Functions\ICIS_IV_A_4.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\5 DMS DLL Functions\ICIS_IV_A_5.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\6 List DLL Functions\ICIS_IV_A_6.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\7 IMS DLL Functions\ICIS_IV_A_7.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\8 LMS DLL Functions\ICIS_IV_A_8.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\9 BIBREF DLL Functions\ICIS_IV_A_9.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\B. JAVA Middleware\ICIS_IV_B.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\B. JAVA Middleware\ICIS_IV_B.zip"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\C. Web Architecture\1 Web Application Framework\ICIS_IV_C_1.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\C. Web Architecture\2 ICIS5 Web Application\ICIS_IV_C_2.doc"
  Delete "$INSTDIR\Document\TDM\IV Technical Development\C. Web Architecture\3 ICIS5 Web Services\ICIS_IV_C_3.doc"
  ;
  Delete "$INSTDIR\Document\TDM\IV Technical Development\ICISDLL-doc.zip"
  ;
  Delete "$INSTDIR\Exes\bantam.dll"
  Delete "$INSTDIR\Exes\BLW32.DLL"
  Delete "$INSTDIR\Exes\Browse.exe"
  Delete "$INSTDIR\Exes\COMDLG32.OCX"
  Delete "$INSTDIR\Exes\DataComp.xls"
  Delete "$INSTDIR\Exes\DFORRT.DLL"
  Delete "$INSTDIR\Exes\DMSWRBK.XLA"
  Delete "$INSTDIR\Exes\f90SQLDVF.dll"
  Delete "$INSTDIR\Exes\GMSInput.exe"
  Delete "$INSTDIR\Exes\GMSSrch.exe"
  Delete "$INSTDIR\Exes\help.ico"
  Delete "$INSTDIR\Exes\icis_diag.exe"
  Delete "$INSTDIR\Exes\icis_validate.exe"
  Delete "$INSTDIR\Exes\ICIS32.dll"
  Delete "$INSTDIR\Exes\ICISForms.exe"
  Delete "$INSTDIR\Exes\ICIS.INI"
  Delete "$INSTDIR\Exes\ICIS-RTV.mdb"
  Delete "$INSTDIR\Exes\ICISworkbook.xla"
  Delete "$INSTDIR\Exes\IDAPI32.DLL"
  Delete "$INSTDIR\Exes\IDODBC32.DLL"
  Delete "$INSTDIR\Exes\IDR20009.DLL"
  Delete "$INSTDIR\Exes\Input2.TXT"
  Delete "$INSTDIR\Exes\Input.TXT"
  Delete "$INSTDIR\Exes\Installation Diagnostic Tool.exe"
  Delete "$INSTDIR\Exes\Data Validation Tool.exe"
  Delete "$INSTDIR\Exes\InTrack.exe"
  Delete "$INSTDIR\Exes\IWIS3.ini"
  Delete "$INSTDIR\Exes\LAUNCHER.exe"
  ; Make a safety backup in the Windows directory, since user might have made modifications he will not
  ; want to lose, he can recover from Windows directory as last option - but not automated here.
  CopyFiles $INSTDIR\Exes\Launcher.txt $WINDIR\Launcher.txt
  Delete "$INSTDIR\Exes\LAUNCHER.TXT"
  Delete "$INSTDIR\Exes\Library.dll"
  Delete "$INSTDIR\Exes\Library.snk"
  Delete "$INSTDIR\Exes\Library.tlb"
  Delete "$INSTDIR\Exes\MFCANS32.DLL"
  Delete "$INSTDIR\Exes\MSVCRT20.DLL"
  Delete "$INSTDIR\Exes\OC30.DLL"
  Delete "$INSTDIR\Exes\PNFldbk.exe"
  Delete "$INSTDIR\Exes\PostgreSQL.ini"
  Delete "$INSTDIR\Exes\PostgresTest.ini"
  Delete "$INSTDIR\Exes\SetGen.EXE"
  Delete "$INSTDIR\Exes\UNZIP32.EXE"
  Delete "$INSTDIR\Exes\vcf132.ocx"
  Delete "$INSTDIR\Exes\DataComp Help\Contents.htm"
  Delete "$INSTDIR\Exes\DataComp Help\Coop Trial Historical Comparison Help.htm"
  Delete "$INSTDIR\Exes\DataComp Help\DataCompHelp.htm"
  Delete "$INSTDIR\Exes\DataComp Help\DataCompHelp.pdf"
  Delete "$INSTDIR\Exes\DataComp Help\International Crop Information System.htm"
  Delete "$INSTDIR\Exes\DataComp Help\Introduction.htm"
  Delete "$INSTDIR\Exes\DataComp Help\Introduction.pdf"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help.htm"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help.pdf"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison.htm"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help.htm"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help.pdf"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever.htm"
  Delete "$INSTDIR\Exes\DataComp Help\Contents_files\filelist.xml"
  Delete "$INSTDIR\Exes\DataComp Help\Contents_files\image001.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Coop Trial Historical Comparison Help_files\filelist.xml"
  Delete "$INSTDIR\Exes\DataComp Help\Coop Trial Historical Comparison Help_files\image001.png"
  Delete "$INSTDIR\Exes\DataComp Help\Coop Trial Historical Comparison Help_files\image002.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Coop Trial Historical Comparison Help_files\image003.png"
  Delete "$INSTDIR\Exes\DataComp Help\Coop Trial Historical Comparison Help_files\image004.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Coop Trial Historical Comparison Help_files\image005.png"
  Delete "$INSTDIR\Exes\DataComp Help\Coop Trial Historical Comparison Help_files\image006.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\International Crop Information System_files\filelist.xml"
  Delete "$INSTDIR\Exes\DataComp Help\International Crop Information System_files\image001.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\International Crop Information System_files\image002.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Introduction_files\filelist.xml"
  Delete "$INSTDIR\Exes\DataComp Help\Introduction_files\image001.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Introduction_files\image002.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Introduction_files\image003.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Introduction_files\image004.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Introduction_files\image005.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Introduction_files\image006.jpg"
  ;
  Delete "$INSTDIR\Exes\DataComp Help\Introduction_files\Thumbs.db"
  ;
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\filelist.xml"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image001.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image002.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image003.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image009.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image010.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image011.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image012.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image014.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image015.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image016.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image017.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image018.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\image019.jpg"
  ;
  Delete "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\Thumbs.db"
  ;
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\filelist.xml"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image001.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image002.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image003.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image004.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image005.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image006.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image007.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image008.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image009.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image010.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image011.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image012.png"
  Delete "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\image013.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\filelist.xml"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image001.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image001.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image002.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image003.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image004.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image005.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image005.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image006.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image007.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image008.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image009.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image010.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image011.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image011.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image012.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image013.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image014.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image015.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image016.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image017.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image018.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image019.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image020.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image021.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image022.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image023.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image024.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image025.png"
  Delete "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\image026.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\filelist.xml"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image001.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image002.png"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image003.gif"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image004.png"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image005.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image006.png"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image007.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image008.png"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image009.jpg"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image010.png"
  Delete "$INSTDIR\Exes\DataComp Help\Study Retriever_files\image011.gif"
  Delete "$INSTDIR\Exes\dmsfiles\help\convert_template.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\dmshelp.css"
  Delete "$INSTDIR\Exes\dmsfiles\help\effects.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\faq.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\generic.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\get_crosslist.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\get_parent.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\gethelp.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\import_layout.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\index.html.lnk"
  Delete "$INSTDIR\Exes\dmsfiles\help\index.html"
  Delete "$INSTDIR\Exes\dmsfiles\help\inspect.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\labels.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\load_study.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\main.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\newbook.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\other_tools.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\parallel.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\retrieve_setgen.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\retrieve_study.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\setup_variables.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\unload_study.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\utilities.htm"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\blank.gif"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\demo_convert_template01.avi"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\demo_convert_template02.avi"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\demo_convert_template03.avi"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_crosslist.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_customizeworkbook.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_definevars.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_getcross.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_importlayout.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_inspect.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_loadstudy.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_newbook.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_retrievesetgen.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_retrievestudy.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\form_unloadstudy.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\hline.gif"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\logo_dmshelp.gif"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\logo_fill.gif"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\logo_icis.gif"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\logo_irri.gif"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_crosslist.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_definevars.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_formatcell.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_getcross.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_importlayout.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_inspect.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_loadstudy.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_newbook.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_protect.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_retrievesetgen.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_retrievestudy.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_unloadstudy.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_utilities.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\menu_validate.JPG"
  Delete "$INSTDIR\Exes\dmsfiles\help\images\untitled.bmp"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\Copy of tree.js"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\tree.js"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\webfxcheckboxtreeitem.js"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\xtree.bak"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\xtree.css"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\xtree.js"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\article-images\tree1.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\article-images\tree2.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\article-images\tree3.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\article-images\tree4.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\blank.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\file.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\foldericon.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\I.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\Lminus.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\Lplus.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\L.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\new.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\openfoldericon.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\pspbrwse.jbf"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\Tminus.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\Tplus.png"
  Delete "$INSTDIR\Exes\dmsfiles\help\xtree\images\T.png"
  Delete "$INSTDIR\Exes\dmsfiles\themes\crops.jpg"
  Delete "$INSTDIR\Exes\dmsfiles\themes\iris.GIF"
  Delete "$INSTDIR\Exes\dmsfiles\themes\irri.GIF"
  Delete "$INSTDIR\Exes\dmsfiles\themes\nunhems.jpg"
  Delete "$INSTDIR\Exes\dmsfiles\themes\rice.bmp"
  Delete "$INSTDIR\Exes\dmsfiles\themes\wheat.bmp"
  Delete "$INSTDIR\Exes\dmsfiles\themes\wheat.png"
  Delete "$INSTDIR\Exes\Document\TDM\ICIS_doc_template.dot"
  Delete "$INSTDIR\Exes\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course.zip"
  Delete "$INSTDIR\Exes\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\Plant Breeding Course.doc"
  Delete "$INSTDIR\Exes\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\Setting up the Training.doc"
  Delete "$INSTDIR\Exes\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\9 13_Deposting of Seed Stock for RYT List - Batch\Deposting of Seed Stock for RYT List - Batch.doc"
  Delete "$INSTDIR\Exes\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\9 13_Deposting of Seed Stock for RYT List - Batch\Training.mdb"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\1 Users and Access\ICIS_III_A_1.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10.htm"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\People and Institute.wiki"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10_files\filelist.xml"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10_files\header.htm"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\GMS_StructureWiki b.txt"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\ICIS02G_GMS_Overview.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\ICIS03K_GMS_Structure.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\ICIS03K_GMS.wki"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\Temp.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\3 List Management\List Management.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\3 List Management\LMS.wki"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\DMS Data Model.jpg"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\DMS.wiki.txt"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\ICIS_III_A_4.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\Table4_3_1.bmp"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\Table4_3_1.JPG"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\TMD DMS Observation Units.bmp"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\TMD DMS Observation Units.JPG"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\5 Inventory Management System\ICIS_III_A_5.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\5 Inventory Management System\IMS.wki"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\6 Gene Management System\GEMS.wki"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\6 Gene Management System\ICIS18L_GEMS.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\8 Location Management System\LDMS Logical Structure.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\8 Location Management System\LDMS Use Case Model.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\9 Bibliographic References\ICIS_III_A_9.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\FundamentalDifferences_MOBY_LSID.pdf"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\LSID_Compliance_Implications.pdf"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\LSID_Compliance_Implications.rtf"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\WhyLSID.pdf"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\WhyMOBY.pdf"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\2 Germplasm Development and Maintenance Methods\ICIS_III_B_2a.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\2 Germplasm Development and Maintenance Methods\ICIS_III_B_2b.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\3 DMS Properties, Traits and Scales\ICIS_III_B_3.DOC"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\3 DMS Properties, Traits and Scales\ICIS-Ontology.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\1 ICIS Application and Database Installation\ICIS_III_C_1.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\2 Setting up a GMS Database\ICIS_III_C_2.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\3 Setting up a DMS Database\ICIS_III_C_3.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\4 Setting up an IMS Database\ICIS_III_C_4_.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up ICIS5 web application\ICIS_III_C_7_linux.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up ICIS5 web application\ICIS_III_C_7_windows.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up ICIS5 web application\ICIS_III_C_7.doc"
  Delete "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up the Web Interface\ICIS_III_C_7.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\1 DLL Architecture\Dll Architecture.wiki"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\1 DLL Architecture\ICIS_IV_A_1.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\10 Integration of Web Services\Document Scrap 'Graham...'.shs"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\10 Integration of Web Services\ICIS 5-WebServices.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\2 ICIS Data Structures\ICIS Data Structures.wiki"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\2 ICIS Data Structures\ICIS_IV_A_2.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\3 DLL Functions for Access Control\ICIS_IV_A_3.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\4 GMS DLL Functions\ICIS_IV_A_4.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\5 DMS DLL Functions\ICIS_IV_A_5.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\6 List DLL Functions\ICIS_IV_A_6.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\7 IMS DLL Functions\ICIS_IV_A_7.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\8 LMS DLL Functions\ICIS_IV_A_8.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\9 BIBREF DLL Functions\ICIS_IV_A_9.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\B. JAVA Middleware\ICIS_IV_B.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\B. JAVA Middleware\ICIS_IV_B.zip"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\C. Web Architecture\1 Web Application Framework\ICIS_IV_C_1.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\C. Web Architecture\2 ICIS5 Web Application\ICIS_IV_C_2.doc"
  Delete "$INSTDIR\Exes\Document\TDM\IV Technical Development\C. Web Architecture\3 ICIS5 Web Services\ICIS_IV_C_3.doc"
  Delete "$INSTDIR\Exes\Fieldbook\Fieldbook.xls"
  Delete "$INSTDIR\Exes\Fieldbook\Pedigree.xls"
  Delete "$INSTDIR\Exes\Fieldbook\PlantingBlocks\BlocksInfo.xls"
  Delete "$INSTDIR\Exes\Fieldbook\SeasonSummary\SeasonSummary05B.xls"
  Delete "$INSTDIR\Exes\Fieldbook\Templates\PlantingBlocks.xlt"
  Delete "$INSTDIR\Exes\Fieldbook\Templates\SeasonSummary.xlt"
  Delete "$INSTDIR\Exes\Help\Contents.htm"
  Delete "$INSTDIR\Exes\Help\DMS WORKBOOK Tutorial.html"
  Delete "$INSTDIR\Exes\Help\Fig50201.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50202.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50203.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50204.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50301.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50302.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50501.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50502.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50503.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50504.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50505.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50506.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50507.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50508.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50509.jpg"
  Delete "$INSTDIR\Exes\Help\Fig5050.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50510.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50511.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50512.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50513.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50514.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50515.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50516.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50517.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50518.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50519.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50520.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50521.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50522.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50523.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50524.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50601.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50602.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50603.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50604.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50605.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50701.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50702.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50703.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50704.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50705.jpg"
  Delete "$INSTDIR\Exes\Help\Fig50706.jpg"
  Delete "$INSTDIR\Exes\Help\Gray_Textured29C6.gif"
  Delete "$INSTDIR\Exes\Help\image1.png"
  Delete "$INSTDIR\Exes\Help\IndexDMS.html"
  Delete "$INSTDIR\Exes\Help\Index.htm"
  Delete "$INSTDIR\Exes\Help\sectio1.jpg"
  Delete "$INSTDIR\Exes\Help\section50100.htm"
  Delete "$INSTDIR\Exes\Help\section50200.htm"
  Delete "$INSTDIR\Exes\Help\section50201.htm"
  Delete "$INSTDIR\Exes\Help\section50202.htm"
  Delete "$INSTDIR\Exes\Help\section50203.htm"
  Delete "$INSTDIR\Exes\Help\section50204.htm"
  Delete "$INSTDIR\Exes\Help\section50205.htm"
  Delete "$INSTDIR\Exes\Help\section50300.htm"
  Delete "$INSTDIR\Exes\Help\section50400.htm"
  Delete "$INSTDIR\Exes\Help\section50401.htm"
  Delete "$INSTDIR\Exes\Help\section50402.htm"
  Delete "$INSTDIR\Exes\Help\section50403.htm"
  Delete "$INSTDIR\Exes\Help\section50404.htm"
  Delete "$INSTDIR\Exes\Help\section50405.htm"
  Delete "$INSTDIR\Exes\Help\section50406.htm"
  Delete "$INSTDIR\Exes\Help\section50407.htm"
  Delete "$INSTDIR\Exes\Help\section50408.htm"
  Delete "$INSTDIR\Exes\Help\section50409.htm"
  Delete "$INSTDIR\Exes\Help\section50500.htm"
  Delete "$INSTDIR\Exes\Help\section50501.htm"
  Delete "$INSTDIR\Exes\Help\section50502.htm"
  Delete "$INSTDIR\Exes\Help\section50503.htm"
  Delete "$INSTDIR\Exes\Help\section50504.htm"
  Delete "$INSTDIR\Exes\Help\section50505.htm"
  Delete "$INSTDIR\Exes\Help\section50506.htm"
  Delete "$INSTDIR\Exes\Help\section50507.htm"
  Delete "$INSTDIR\Exes\Help\section50508.htm"
  Delete "$INSTDIR\Exes\Help\section50509.htm"
  Delete "$INSTDIR\Exes\Help\section50510.htm"
  Delete "$INSTDIR\Exes\Help\section50511.htm"
  Delete "$INSTDIR\Exes\Help\section50600.htm"
  Delete "$INSTDIR\Exes\Help\section50601.htm"
  Delete "$INSTDIR\Exes\Help\section50602.htm"
  Delete "$INSTDIR\Exes\Help\section50700.htm"
  Delete "$INSTDIR\Exes\Help\section50701.htm"
  Delete "$INSTDIR\Exes\Help\section50702.htm"
  Delete "$INSTDIR\Exes\Help\section50703a.htm"
  Delete "$INSTDIR\Exes\Help\section50703.htm"
  Delete "$INSTDIR\Exes\Help\section50704.htm"
  Delete "$INSTDIR\Exes\Help\Section50705.htm"
  Delete "$INSTDIR\Exes\Help\Workbook.html"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\Contents.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\Gray_Textured29C6.gif"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\image1.png"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\Index.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\sectio1.jpg"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50100.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50200.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50201.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50202.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50203.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50204.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50205.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50300.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50400.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50401.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50402.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50403.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50404.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50405.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50406.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50407.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50408.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50409.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50500.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50501.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50502.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50503.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50504.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50505.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50506.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50507.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50508.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50509.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50510.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50511.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50600.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50601.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50602.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50700.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50701.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50702.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50703a.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50703.htm"
  Delete "$INSTDIR\Exes\Help\_vti_cnf\section50704.htm"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSBkgrd.gif"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSDesc2.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSDesc.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSInMn2.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSInMn.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSListD.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSListM.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSListO.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSMenu.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSObs2.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSObs.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSQryC.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSQryD.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSRetM.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\Dmsrl1.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\Dmsrl2.jpg"
  Delete "$INSTDIR\Exes\Help\DMSImage\DmsrlIn.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DmsRL.JPG"
  Delete "$INSTDIR\Exes\Help\DMSImage\DMSTutor.JPG"
  Delete "$INSTDIR\Exes\Help\images\image1.png"
  Delete "$INSTDIR\Exes\Help\section50200_files\_vti_cnf\image001.png"
  Delete "$INSTDIR\Exes\Help\section50201_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50201_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50201_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50201_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50201_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50202_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50202_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50202_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50202_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50202_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50204_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50204_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50204_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50204_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50204_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50205_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50205_files\image001.gif"
  Delete "$INSTDIR\Exes\Help\section50205_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50205_files\_vti_cnf\image001.gif"
  Delete "$INSTDIR\Exes\Help\section50300_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50300_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50300_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50300_files\image003.png"
  Delete "$INSTDIR\Exes\Help\section50300_files\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50300_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50300_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50501_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50501_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50501_files\image002.gif"
  Delete "$INSTDIR\Exes\Help\section50501_files\oledata.mso"
  Delete "$INSTDIR\Exes\Help\section50501_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50501_files\_vti_cnf\image002.gif"
  Delete "$INSTDIR\Exes\Help\section50501_files\_vti_cnf\oledata.mso"
  Delete "$INSTDIR\Exes\Help\section50502_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50502_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50502_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50502_files\image003.png"
  Delete "$INSTDIR\Exes\Help\section50502_files\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50502_files\image005.png"
  Delete "$INSTDIR\Exes\Help\section50502_files\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50502_files\image007.png"
  Delete "$INSTDIR\Exes\Help\section50502_files\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50502_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50502_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50502_files\_vti_cnf\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50502_files\_vti_cnf\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50502_files\_vti_cnf\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50503_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50503_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50503_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50503_files\image003.png"
  Delete "$INSTDIR\Exes\Help\section50503_files\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50503_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50503_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50503_files\_vti_cnf\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50504_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50504_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50504_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50504_files\image003.png"
  Delete "$INSTDIR\Exes\Help\section50504_files\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50504_files\image005.png"
  Delete "$INSTDIR\Exes\Help\section50504_files\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50504_files\image007.png"
  Delete "$INSTDIR\Exes\Help\section50504_files\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50504_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50504_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50504_files\_vti_cnf\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50504_files\_vti_cnf\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50504_files\_vti_cnf\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50505_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50505_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50505_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50505_files\image003.png"
  Delete "$INSTDIR\Exes\Help\section50505_files\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50505_files\image005.png"
  Delete "$INSTDIR\Exes\Help\section50505_files\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50505_files\image007.png"
  Delete "$INSTDIR\Exes\Help\section50505_files\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50505_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50505_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50505_files\_vti_cnf\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50505_files\_vti_cnf\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50505_files\_vti_cnf\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50506_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50506_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50506_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50506_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50506_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50508_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50508_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50508_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50508_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50508_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50509_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50509_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50509_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50509_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50509_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50510_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50510_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\image003.png"
  Delete "$INSTDIR\Exes\Help\section50510_files\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\image005.png"
  Delete "$INSTDIR\Exes\Help\section50510_files\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\image007.png"
  Delete "$INSTDIR\Exes\Help\section50510_files\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\image009.png"
  Delete "$INSTDIR\Exes\Help\section50510_files\image010.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50510_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\_vti_cnf\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\_vti_cnf\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\_vti_cnf\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50510_files\_vti_cnf\image010.jpg"
  Delete "$INSTDIR\Exes\Help\section50511_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50511_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50511_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50511_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50511_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50601_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50601_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50601_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50601_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50601_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50602_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50602_files\image001.png"
  Delete "$INSTDIR\Exes\Help\section50602_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50602_files\image003.png"
  Delete "$INSTDIR\Exes\Help\section50602_files\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50602_files\image005.png"
  Delete "$INSTDIR\Exes\Help\section50602_files\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50602_files\image007.png"
  Delete "$INSTDIR\Exes\Help\section50602_files\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50602_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50602_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50602_files\_vti_cnf\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50602_files\_vti_cnf\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50602_files\_vti_cnf\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50704_files\image001.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image003.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image005.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image007.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image009.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image010.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image011.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\image012.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\_vti_cnf\filelist.xml"
  Delete "$INSTDIR\Exes\Help\section50704_files\_vti_cnf\image002.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\_vti_cnf\image004.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\_vti_cnf\image006.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\_vti_cnf\image008.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\_vti_cnf\image010.jpg"
  Delete "$INSTDIR\Exes\Help\section50704_files\_vti_cnf\image012.jpg"
  Delete "$INSTDIR\Exes\icis_diag_files\Central DMS.txt"
  Delete "$INSTDIR\Exes\icis_diag_files\Central GMS.txt"
  Delete "$INSTDIR\Exes\icis_diag_files\CREDITS.txt"
  Delete "$INSTDIR\Exes\icis_diag_files\dms.sql"
  Delete "$INSTDIR\Exes\icis_diag_files\gms.sql"
  Delete "$INSTDIR\Exes\icis_diag_files\icis-diag.chm"
  Delete "$INSTDIR\Exes\icis_diag_files\LICENSE.txt"
  Delete "$INSTDIR\Exes\icis_diag_files\Local DMS.txt"
  Delete "$INSTDIR\Exes\icis_diag_files\Local GMS.txt"
  Delete "$INSTDIR\Exes\icis_diag_files\README.txt"
  Delete "$INSTDIR\Exes\icis_diag_files\results.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\Central DMS_PATCH.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\Central DMS.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\Central GMS_PATCH.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\Central GMS.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\CREDITS.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\dms.sql"
  Delete "$INSTDIR\Exes\icis_diag_resources\dmstest.sql"
  Delete "$INSTDIR\Exes\icis_diag_resources\gms.sql"
  Delete "$INSTDIR\Exes\icis_diag_resources\gmstest.sql"
  Delete "$INSTDIR\Exes\icis_diag_resources\ICIS Installation Diagnostic Tool - RESULTS.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\ICIS_DIAG.INI"
  Delete "$INSTDIR\Exes\icis_diag_resources\icis-diag.chm"
  Delete "$INSTDIR\Exes\icis_diag_resources\LICENSE.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\Local DMS_PATCH.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\Local DMS.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\Local GMS_PATCH.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\Local GMS.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\README.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\results.txt"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\check.jpg"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\CRIL Logo_4.jpg"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\icis_background.JPG"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\icis_diag.jpg"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\icis_validate.jpg"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\icis.JPG"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\irri_logo.gif"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\Presentation1.jpg"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\Presentation1.ppt"
  Delete "$INSTDIR\Exes\icis_diag_resources\images\Thumbs.db"
  Delete "$INSTDIR\Exes\icis_validate_files\CREDITS.txt"
  Delete "$INSTDIR\Exes\icis_validate_files\FEATURES.txt"
  Delete "$INSTDIR\Exes\icis_validate_files\icis-validate.chm"
  Delete "$INSTDIR\Exes\icis_validate_files\LICENSE.txt"
  Delete "$INSTDIR\Exes\icis_validate_files\README.txt"
  Delete "$INSTDIR\Exes\icis_validate_files\results_2007_03_01.txt"
  Delete "$INSTDIR\Exes\icis_validate_files\results_3.txt"
  Delete "$INSTDIR\Exes\icis_validate_files\results1.txt"
  Delete "$INSTDIR\Exes\icis_validate_files\results.txt"
  Delete "$INSTDIR\Exes\resources\icis_diag\Central DMS.txt"
  Delete "$INSTDIR\Exes\resources\icis_diag\Central GMS.txt"
  Delete "$INSTDIR\Exes\resources\icis_diag\CREDITS.txt"
  Delete "$INSTDIR\Exes\resources\icis_diag\dms.sql"
  Delete "$INSTDIR\Exes\resources\icis_diag\gms.sql"
  Delete "$INSTDIR\Exes\resources\icis_diag\icis_diag.jpg"
  Delete "$INSTDIR\Exes\resources\icis_diag\icis-diag.chm"
  Delete "$INSTDIR\Exes\resources\icis_diag\LICENSE.txt"
  Delete "$INSTDIR\Exes\resources\icis_diag\Local DMS.txt"
  Delete "$INSTDIR\Exes\resources\icis_diag\Local GMS.txt"
  Delete "$INSTDIR\Exes\resources\icis_diag\README.txt"
  Delete "$INSTDIR\Exes\resources\icis_diag\results.txt"
  Delete "$INSTDIR\Exes\resources\icis_diag\images\check.jpg"
  Delete "$INSTDIR\Exes\resources\icis_diag\images\icis_background.JPG"
  Delete "$INSTDIR\Exes\resources\icis_diag\images\icis_diag.jpg"
  Delete "$INSTDIR\Exes\resources\icis_diag\images\icis_validate.jpg"
  Delete "$INSTDIR\Exes\resources\icis_diag\images\icis.JPG"
  Delete "$INSTDIR\Exes\resources\icis_diag\images\Presentation1.jpg"
  Delete "$INSTDIR\Exes\resources\icis_diag\images\Presentation1.ppt"
  Delete "$INSTDIR\Setup\Redist\50comupd.exe"
  Delete "$INSTDIR\Setup\Redist\DCOM95.EXE"
  Delete "$INSTDIR\Setup\Redist\DCOM98.EXE"
  Delete "$INSTDIR\Setup\Redist\Del_Ini.exe"
  Delete "$INSTDIR\Setup\Redist\DELINI.BAT"
  Delete "$INSTDIR\Setup\Redist\jet40sp3_comp.exe"
  Delete "$INSTDIR\Setup\Redist\mdac_typ.exe"
  Delete "$INSTDIR\Setup\Redist\MFC4X.EXE"
  Delete "$INSTDIR\Setup\Redist\msnsetup_min.exe"
  Delete "$INSTDIR\Setup\Redist\Redist.ini"
  Delete "$INSTDIR\Setup\Redist\Riched32.EXE"
  Delete "$INSTDIR\Setup\Redist\VBRun60sp3.exe"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\_SETUP.DLL"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\_SETUP.LIB"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\DAOCORE.1"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\DAOCORE.2"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\DISK1.ID"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\JETISAM.Z"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\README.TXT"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\SETUP.EXE"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\SETUP.INS"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\SETUP.ISS"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\setup.log"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\SETUP.PKG"
  Delete "$INSTDIR\Setup\Redist\Dao\3.0\UNINST.EXE"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\_INST32I.EX_"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\_SETUP.DLL"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\_SETUP.LIB"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\DAOCORE.1"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\DAOCORE.2"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\DAOCORE.3"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\DAOMIN.ISS"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\DISK1.ID"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\DISK2.ID"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\DISK3.ID"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\NOSDK.ISS"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\SETUP.EXE"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\SETUP.INS"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\SETUP.ISS"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\setup.log"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\SETUP.PKG"
  Delete "$INSTDIR\Setup\Redist\Dao\3.5\UNINST.EXE"
  Delete "$INSTDIR\Setup\GMS\_INST32I.EX_"
  Delete "$INSTDIR\Setup\GMS\_ISDEL.EXE"
  Delete "$INSTDIR\Setup\GMS\_SETUP.DLL"
  Delete "$INSTDIR\Setup\GMS\_sys1.cab"
  Delete "$INSTDIR\Setup\GMS\_user1.cab"
  Delete "$INSTDIR\Setup\GMS\data1.cab"
  Delete "$INSTDIR\Setup\GMS\DATA.TAG"
  Delete "$INSTDIR\Setup\GMS\lang.dat"
  Delete "$INSTDIR\Setup\GMS\layout.bin"
  Delete "$INSTDIR\Setup\GMS\os.dat"
  Delete "$INSTDIR\Setup\GMS\_OLD.ins"
  Delete "$INSTDIR\Setup\GMS\Setup.bmp"
  Delete "$INSTDIR\Setup\GMS\Setup.EXE"
  Delete "$INSTDIR\Setup\GMS\Setup.INI"
  Delete "$INSTDIR\Setup\GMS\Setup.ins"
  Delete "$INSTDIR\Setup\GMS\Setup.lid"
  
  RMDIR "$INSTDIR\Redist\Dao\3.5\"
  RMDIR "$INSTDIR\Redist\Dao\3.0\"
  RMDIR "$INSTDIR\Redist\Dao\"
  RMDIR "$INSTDIR\Redist\"
  RMDIR "$INSTDIR\GMS\"
  RMDIR "$INSTDIR\Exes\resources\icis_diag\images\"
  RMDIR "$INSTDIR\Exes\resources\icis_diag\"
  RMDIR "$INSTDIR\Exes\resources\"
  RMDIR "$INSTDIR\Exes\icis_validate_files\"
  RMDIR "$INSTDIR\Exes\icis_diag_resources\images\"
  RMDIR "$INSTDIR\Exes\icis_diag_resources\"
  RMDIR "$INSTDIR\Exes\icis_diag_files\"
  RMDIR "$INSTDIR\Exes\Help\section50704_files\"
  RMDIR "$INSTDIR\Exes\Help\section50602_files\"
  RMDIR "$INSTDIR\Exes\Help\section50601_files\"
  RMDIR "$INSTDIR\Exes\Help\section50511_files\"
  RMDIR "$INSTDIR\Exes\Help\section50510_files\"
  RMDIR "$INSTDIR\Exes\Help\section50509_files\"
  RMDIR "$INSTDIR\Exes\Help\section50508_files\"
  RMDIR "$INSTDIR\Exes\Help\section50506_files\"
  RMDIR "$INSTDIR\Exes\Help\section50505_files\"
  RMDIR "$INSTDIR\Exes\Help\section50504_files\"
  RMDIR "$INSTDIR\Exes\Help\section50503_files\"
  RMDIR "$INSTDIR\Exes\Help\section50502_files\"
  RMDIR "$INSTDIR\Exes\Help\section50501_files\"
  RMDIR "$INSTDIR\Exes\Help\section50300_files\"
  RMDIR "$INSTDIR\Exes\Help\section50205_files\"
  RMDIR "$INSTDIR\Exes\Help\section50204_files\"
  RMDIR "$INSTDIR\Exes\Help\section50202_files\"
  RMDIR "$INSTDIR\Exes\Help\section50201_files\"
  RMDIR "$INSTDIR\Exes\Help\section50200_files\"
  RMDIR "$INSTDIR\Exes\Help\images\"
  RMDIR "$INSTDIR\Exes\Help\DMSImage\"
  RMDIR "$INSTDIR\Exes\Help\"
  RMDIR "$INSTDIR\Exes\Fieldbook\Templates\"
  RMDIR "$INSTDIR\Exes\Fieldbook\SeasonSummary\"
  RMDIR "$INSTDIR\Exes\Fieldbook\PlantingBlocks\"
  RMDIR "$INSTDIR\Exes\Fieldbook\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\C. Web Architecture\3 ICIS5 Web Services\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\C. Web Architecture\2 ICIS5 Web Application\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\C. Web Architecture\1 Web Application Framework\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\C. Web Architecture\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\B. JAVA Middleware\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\9 BIBREF DLL Functions\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\8 LMS DLL Functions\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\7 IMS DLL Functions\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\6 List DLL Functions\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\5 DMS DLL Functions\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\4 GMS DLL Functions\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\3 DLL Functions for Access Control\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\2 ICIS Data Structures\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\10 Integration of Web Services\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\1 DLL Architecture\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\"
  RMDIR "$INSTDIR\Exes\Document\TDM\IV Technical Development\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up the Web Interface\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up ICIS5 web application\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\6 Setting up the Location Manager\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\5 Setting up a GEMS Database\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\4 Setting up an IMS Database\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\3 Setting up a DMS Database\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\2 Setting up a GMS Database\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\1 ICIS Application and Database Installation\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\C. Administrating ICIS Implementations\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\3 DMS Properties, Traits and Scales\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\2 Germplasm Development and Maintenance Methods\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\9 Bibliographic References\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\8 Location Management System\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\7 Genetic Resources Information Management System\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\6 Gene Management System\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\5 Inventory Management System\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\3 List Management\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10_files\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\1 Users and Access\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\"
  RMDIR "$INSTDIR\Exes\Document\TDM\III Administration\"
  RMDIR "$INSTDIR\Exes\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\9 13_Deposting of Seed Stock for RYT List - Batch\"
  RMDIR "$INSTDIR\Exes\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\"
  RMDIR "$INSTDIR\Exes\Document\TDM\II Users Manual and Training Material\"
  RMDIR "$INSTDIR\Exes\Document\TDM\"
  RMDIR "$INSTDIR\Exes\Document\"
  RMDIR "$INSTDIR\Exes\dmsfiles\themes\"
  RMDIR "$INSTDIR\Exes\dmsfiles\help\xtree\images\"
  RMDIR "$INSTDIR\Exes\dmsfiles\help\xtree\article-images\"
  RMDIR "$INSTDIR\Exes\dmsfiles\help\xtree\"
  RMDIR "$INSTDIR\Exes\dmsfiles\help\images\"
  RMDIR "$INSTDIR\Exes\dmsfiles\help\"
  RMDIR "$INSTDIR\Exes\dmsfiles\"
  RMDIR "$INSTDIR\Exes\DataComp Help\Study Retriever_files\"
  RMDIR "$INSTDIR\Exes\DataComp Help\Parent Comparison Help_files\"
  RMDIR "$INSTDIR\Exes\DataComp Help\Line vs Checks Comparison_files\"
  RMDIR "$INSTDIR\Exes\DataComp Help\Line Historical Comparison Help_files\"
  RMDIR "$INSTDIR\Exes\DataComp Help\Introduction_files\"
  RMDIR "$INSTDIR\Exes\DataComp Help\International Crop Information System_files\"
  RMDIR "$INSTDIR\Exes\DataComp Help\Coop Trial Historical Comparison Help_files\"
  RMDIR "$INSTDIR\Exes\DataComp Help\Contents_files\"
  RMDIR "$INSTDIR\Exes\DataComp Help\"
  RMDIR "$INSTDIR\Exes\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\C. Web Architecture\3 ICIS5 Web Services\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\C. Web Architecture\2 ICIS5 Web Application\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\C. Web Architecture\1 Web Application Framework\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\C. Web Architecture\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\B. JAVA Middleware\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\9 BIBREF DLL Functions\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\8 LMS DLL Functions\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\7 IMS DLL Functions\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\6 List DLL Functions\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\5 DMS DLL Functions\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\4 GMS DLL Functions\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\3 DLL Functions for Access Control\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\2 ICIS Data Structures\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\10 Integration of Web Services\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\1 DLL Architecture\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\A. Windows Application Programming Interface\"
  RMDIR "$INSTDIR\Document\TDM\IV Technical Development\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up the Web Interface\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\7 Setting up ICIS5 web application\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\6 Setting up the Location Manager\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\5 Setting up a GEMS Database\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\4 Setting up an IMS Database\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\3 Setting up a DMS Database\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\2 Setting up a GMS Database\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\1 ICIS Application and Database Installation\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\C. Administrating ICIS Implementations\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\3 DMS Properties, Traits and Scales\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\2 Germplasm Development and Maintenance Methods\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\1 Unique Identification\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\B. Ontologies and Controlled Vocabularies\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\9 Bibliographic References\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\8 Location Management System\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\7 Genetic Resources Information Management System\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\6 Gene Management System\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\5 Inventory Management System\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\4 Data Management System\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\3 List Management\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\2 Genealogy Management System\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\ICIS_III_A_10_files\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\10 People and Institutes\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\1 Users and Access\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\A. Use-Cases  Data Models and Schemata\"
  RMDIR "$INSTDIR\Document\TDM\III Administration\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\9 13_Deposting of Seed Stock for RYT List - Batch\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\8 12_Replicated Yield Trials\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\7 11_Depositing of Seed Stock  for F5 List - Interactive\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\6 10_Advancing Lines with batch processing tools\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\5 08_09 Using Workbook to manage evaluation data\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\4 07_Advancing Lines with interactive tools\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\3 06_Reserving of Seed Stock for HB List\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\2 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\14 18_Using Browse for Pedigree Management\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\13 17_Importing Nursery Lists\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\12 16_Setting up Nursery Templates\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\11 15_Entering historical pedigrees into IRIS\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\10 14_Querying the DMS database\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\1 01&2_Introduction\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\09 13_Deposting of Seed Stock for RYT List - Batch\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\08 12_Replicated Yield Trials\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\07 11_Managing Seed Stock\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\07 11_Depositing of Seed Stock  for F5 List - Interactive\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\06 10_Advancing Lines with batch processing tools\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\05 08_09 Using Workbook to manage evaluation data\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\04 07_Advancing Lines with interactive tools\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\03 06_Reserving of Seed Stock for HB List\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\02 03&4&5_Making Crosses and Establishing the Pedigree Nurseries\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\01 01&2_Introduction\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\C. Breeder's Training Course\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\B. Web Interface\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\9 ICIS Inventory Tracking\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\8 DMS Retriever\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\7 ICIS Workbook\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\6 IRRI Breeding applications\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\5 GMS Input\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\4 SET GENERATION\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\3 GMS Browse\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\2 GMS Search\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\11 ICIS Bioinformatic Workbench\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\10 GRIM Application\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\1 Launcher\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\A. Application Programs\"
  RMDIR "$INSTDIR\Document\TDM\II Users Manual and Training Material\"
  RMDIR "$INSTDIR\Document\TDM\I Overview\B Implementation\"
  RMDIR "$INSTDIR\Document\TDM\I Overview\A Introduction\"
  RMDIR "$INSTDIR\Document\TDM\I Overview\"
  RMDIR "$INSTDIR\Document\TDM\"
  RMDIR "$INSTDIR\Document\"
  RMDIR "$INSTDIR\Database\Template\Upload Tool\"
  RMDIR "$INSTDIR\Database\Template\Query to Upload\"
  RMDIR "$INSTDIR\Database\Template\Query to COnvert\"
  RMDIR "$INSTDIR\Database\Template\Local\Postgres\"
  RMDIR "$INSTDIR\Database\Template\Local\MySQL\"
  RMDIR "$INSTDIR\Database\Template\Local\"
  RMDIR "$INSTDIR\Database\Template\Central\"
  RMDIR "$INSTDIR\Database\Template\"
  RMDIR "$INSTDIR"
  ; Just in case the user might miss his options, for instance if he just
  ; uninstalls WTE 2.x and later wants to install WTE 2.1, put his ini file in WINDOWS
  ; as a safety backup copy - there are many things set up, it will be tedious to
  ; reproduce from scratch. The installer will reuse this file if it finds it.
  CopyFiles $INSTDIR\Exes\$Crop.ini $WINDIR\$Crop.ini
  ;RMDir $INSTDIR\ICIS5
  ; Delete shortcuts to program and ODBC sources
  Delete "$DESKTOP\ICIS 5.LNK"
  Delete "$DESKTOP\ODBC Data Sources.LNK"
  DeleteRegKey /ifempty HKCU "Software\WTE"
  ; Remove Add/Remove Programs entry too:
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "DisplayName"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "UninstallString"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "InstallLocation"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "DisplayIcon"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "Publisher"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "SupportInformation"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "ProductID"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "DisplayVersion"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "VersionMajor"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "VersionMinor"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "NoModify"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "NoRepair"
  ReadRegStr $Crop HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "Crop"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3" "Crop"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\IWIS3"
  ; Remove ODBC data source GMS Central
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "DBQ"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "Driver"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "DriverId"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "FIL"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "SafeTransactions"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "ImplicitCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "MaxBufferSize"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "PageTimeout"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "Threads"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-GMS" "UserCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-CENTRAL-GMS"
  ; Remove ODBC data source DMS Central
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "DBQ"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "Driver"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "DriverId"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "FIL"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "SafeTransactions"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "ImplicitCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "MaxBufferSize"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "PageTimeout"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "Threads"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-CENTRAL-DMS" "UserCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-CENTRAL-DMS"
  ; Remove ODBC data source GMS Local
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "DBQ"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "Driver"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "DriverId"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "FIL"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "SafeTransactions"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "ImplicitCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "MaxBufferSize"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "PageTimeout"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "Threads"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-GMS" "UserCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-LOCAL-GMS"
  ; Remove ODBC data source DMS Local
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "DBQ"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "Driver"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "DriverId"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "FIL"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "SafeTransactions"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "ImplicitCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "MaxBufferSize"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "PageTimeout"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "Threads"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-LOCAL-DMS" "UserCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-LOCAL-DMS"
  ; Remove ODBC data source IMS (Inventory Management System)
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "DBQ"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "Driver"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "DriverId"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "FIL"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "SafeTransactions"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "ImplicitCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "MaxBufferSize"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "PageTimeout"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "Threads"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\$Crop-WGB-IMS" "UserCommitSync"
  DeleteRegValue HKCU "Software\ODBC\ODBC.INI\ODBC Data Sources" "$Crop-WGB-IMS"
  Delete $INSTDIR\Database\$Crop\Local\$Crop-WGB-RTV.mdb
  Delete $INSTDIR\Exes\$Crop.ini

  ; Check if the mapped network drive is still there, then remove that
  StrCpy $MappedDrive "C:\ICIS5"
  ${un.GetDrives} "NET" "un.RecoverMappedDrive"
  ; It wasn't found, so try to add it, recovering which drive letter was assigned
  ${If} $MappedDrive <> "C:\ICIS5"
     ; Implementing STU's solution (he is from Shropshire, England)
     ReadEnvStr $R0 COMSPEC
     nsExec::ExecToStack '$R0 /C net use /delete $MappedDrive'
     Pop $R0
  ${EndIf}
  ; Delete the local databases if the user wants to
  ${Switch} $LANGUAGE
    ${Case} ${LANG_SPANISH}
      MessageBox MB_OKCANCEL "Quieres borrar las bases de datos locales también" IDOK DelMe IDCANCEL NoDel
      ${Break}
    ${Case} ${LANG_DANISH}
      MessageBox MB_OKCANCEL "Vil du også slette de lokale databaser?" IDOK DelMe IDCANCEL NoDel
      ${Break}
    ${CaseElse} ; Default will be ${LANG_ENGLISH} that´s why it is not mentioned above
      MessageBox MB_OKCANCEL "Do you want to delete the local databases as well?" IDOK DelMe IDCANCEL NoDel
      ${Break}
  ${EndSwitch}
  DelMe:
    Delete $INSTDIR\Database\$Crop\Local\$Crop-LOCAL-DMS.mdb
    Delete $INSTDIR\Database\$Crop\Local\$Crop-LOCAL-GMS.mdb
  NoDel:
  ; We need a series of RMDIR to remove empty directories
  ; ... for now just remove the directories created by this installer
  RMDIR $INSTDIR\Database\$Crop\Central
  RMDIR $INSTDIR\Database\$Crop\Local
  RMDIR $INSTDIR\Database\$Crop
  RMDIR $INSTDIR\Database
SectionEnd

Function un.RecoverMappedDrive
  IfFileExists $9EXES\ICIS32.DLL 0 +3
     StrCpy $MappedDrive $9 1
     StrCpy $MappedDrive "$MappedDrive:"
  Push $0
FunctionEnd

;--------------------------------
;Uninstaller initialization

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd
