#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>

Func MyErrFunc()
    $HexNumber = Hex($oMyError.number, 8)
    ConsoleWrite("We intercepted a COM Error !" & @LF & _
            "Number is: " & $HexNumber & @LF & _
            "Windescription is: " & $oMyError.windescription & @LF)
    Return SetError(1, $HexNumber) ; something to check for when this function returns
EndFunc
$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc") ; Install a custom error handler

local $curdir = @WorkingDir & "\UOC"
local $client = $curdir & "\client.exe"
local $sFilePath = $curdir & "\calypso.ini"

Local $sRead = IniRead($sFilePath, "STARTUP", "ShowNoAdminMessage", "false")

if $sRead == "false" then
if Not IsAdmin() then
Local $hGUI0 = GUICreate("CALYPSO",450,120)
GUICtrlCreateLabel("Attention: dans les versions recentes de Windows," & @LF & _
  "Ultima Online n'arrive pas a se connecter au serveru via Internet." & @LF & _
  "Si vous rencontrez ce problème, essayez de lancer CALYPSO en tant qu'administrateur.", 10, 10)
Local $iOKButton = GUICtrlCreateButton("OK", 200, 60, 65)
Local $iNoButton = GUICtrlCreateButton("Ne pas me le rappeler la prochaine fois", 140, 90)
GUISetState(@SW_SHOW, $hGUI0)
Local $iMsg = 0
While 1
    $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $iOKButton
            ExitLoop
        Case $iNoButton
            IniWrite($sFilePath, "STARTUP", "ShowNoAdminMessage", "true")            
            ExitLoop
        Case $GUI_EVENT_CLOSE
            ExitLoop
    EndSwitch
WEnd
GUIDelete($hGUI0) 
endif
endif

local $hGUI = GUICreate("CALYPSO",200,40)
GUICtrlCreateLabel("Contact du serveur en cours...", 30, 10)
GUISetState(@SW_SHOW, $hGUI)

$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
$oHTTP.Open("GET", "https://kokliko.top/login.cfg")
$oHTTP.Send()
if Not @error then
 $oReceived = $oHTTP.ResponseText
 $oStatusCode = $oHTTP.Status
 FileCopy($curdir & "\login.cfg",$curdir & "\login-backup.cfg",1)
 FileDelete($curdir & "\login.cfg")
 If $oStatusCode == 200 then
  $file = FileOpen($curdir & "\login.cfg", 2) ; The value of 2 overwrites the file if it already exists
  FileWrite($file, $oReceived)
  FileClose($file)
 else
  MsgBox($MB_SYSTEMMODAL, "CALYPSO", "Oups... Impossible de recuperer l'adresse du serveur de jeu, la derniere adresse connue sera utilisee.")
  FileCopy($curdir & "\login-backup.cfg",$curdir & "\login.cfg",1)
 EndIf
 FileDelete($curdir & "\login-backup.cfg")
else
  MsgBox($MB_SYSTEMMODAL, "CALYPSO", "Impossible de recuperer l'adresse du serveur de jeu, la derniere adresse connue sera utilisee.")
endif

GUIDelete($hGUI)

local $regpath = ""
$regpath = "HKEY_LOCAL_MACHINE\SOFTWARE\Origin Worlds Online\Ultima Online\ABC"
RegWrite($regpath,"ExePath","REG_SZ",$client)
RegWrite($regpath,"InstCDPath","REG_SZ",$curdir)
RegWrite($regpath,"StartExePath","REG_SZ",$curdir&"\uo.exe")
RegWrite($regpath,"PatchExePath","REG_SZ",$curdir&"\uopatch.exe")
RegWrite($regpath,"Upgraded","REG_SZ","Yes")
$regpath = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Origin Worlds Online\Ultima Online\ABC"
RegWrite($regpath,"ExePath","REG_SZ",$client)
RegWrite($regpath,"InstCDPath","REG_SZ",$curdir)
RegWrite($regpath,"StartExePath","REG_SZ",$curdir&"\uo.exe")
RegWrite($regpath,"PatchExePath","REG_SZ",$curdir&"\uopatch.exe")
RegWrite($regpath,"Upgraded","REG_SZ","Yes")

Run($client,$curdir)
