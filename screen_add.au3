
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ### Form=f:\dictionary\ui.kxf
$Form1_1 = GUICreate("Form1", 712, 65, 214, 145)
$Input1 = GUICtrlCreateInput("A", 8, 0, 329, 21, BitOR($ES_AUTOHSCROLL,$ES_READONLY))
$Input2 = GUICtrlCreateInput("A", 368, 0, 329, 21, BitOR($ES_AUTOHSCROLL,$ES_READONLY))
$Button1 = GUICtrlCreateButton("OK", 304, 32, 75, 25, 0)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###



Opt("MouseCoordMode", 0)        ;1=absolute, 0=relative, 2=client




;INSERT INTO table_name (ÁÐ1, ÁÐ2,...) VALUES (Öµ1, Öµ2,....)


$file_dict = FileOpen("xiang_add.dict", 1+128)


Func WriteWord($w, $e)
	$e = StringReplace($e, @CRLF, "@CRLF")
	FileWriteLine($file_dict, $w&@TAB&$e)
EndFunc


$file_wordlist = FileOpen("xiang_add.txt", 0)
$wordpre = ''

func GetNextWord()
	Do
		$line = FileReadLine($file_wordlist)
		$pos = StringInStr($line, ' ')
		if $pos==0 then
			FileClose($file_dict)			
			Exit			
		EndIf		
		$word = StringLeft($line, $pos-1)
	Until $wordpre <> $word 
	$wordpre = $word
	return $word
EndFunc

$explanation = ''

$count = 1

Func Process()
	ClipPut('')
	$word = GetNextWord()
	if $count ==1 then 
		GUICtrlSetData($Input1, $word)
		Sleep(10)
		MouseMove(15,30,0)
		Sleep(150)
		$count = 0
	Else
		GUICtrlSetData($Input2, $word)
		Sleep(10)
		MouseMove(375,30,0)
		Sleep(150)
		$count = 1
	EndIf
	Send("!c")
	Sleep(10)
	$temp = StringReplace(ClipGet(), "  ¼òÃ÷Ó¢ºº´Êµä"&@CRLF, "")
	if $temp==$explanation Or $temp=='' then
		Sleep(150)
		Send("!c")
		Sleep(10)
		$temp = StringReplace(ClipGet(), "  ¼òÃ÷Ó¢ºº´Êµä"&@CRLF, "")
		if $temp==$explanation Or $temp=='' then	
			Return
		EndIf		
	EndIf
	
	$explanation=$temp
	WriteWord($word, $explanation)
EndFunc

Sleep(200)
MouseMove(15,30,0)
Sleep(200)
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
		Case $Button1
			FileClose($file_dict)		
			Exit
	EndSwitch
	Process()
WEnd

