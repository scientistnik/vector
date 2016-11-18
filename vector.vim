function! VectorSerVar(os)
	if a:os == "windows"
		let g:vector_ip = "192.168.3.116"
	else
		let g:vector_ip = "192.168.3.115"
	endif
	let g:vector_port = "20000"
	echom 'ip:'.g:vector_ip .' port: '. g:vector_port
endfunction

function! Vector(how)
	if a:how == "all"
		let msg = join(getline(1,'$'), "\n")
	else
		let msg = VectorMethod()
		" line 2 have methods ?
		" last line have "," ?
		echom msg
		return
	endif

	" first line have .create ?
	call VectorSend(g:vector_ip, g:vector_port, msg)
endfunction

function! VectorMethod()
python3 << EOF
import vim
import re

vim.command("let sline = 1")
vim.command("let fline = 2")

buffer = vim.current.buffer
window = vim.current.window

cursor = window.cursor

vim.command('normal [{')
cline = window.cursor[0]-1

line = buffer[cline]

oline = cline
while re.match( r'^\t*(methods)? *:.*=> %q{',line) == None:
	vim.command('normal [{')
	cline = window.cursor[0]-1

	if oline == cline:
		print("Dont found start method")
		#return ""
		break
	oline = cline

	line = buffer[cline]

sline = cline
vim.command('let sline = ' + str(sline+1))

vim.command('normal ]}')
cline = window.cursor[0]-1
if cline == oline:
	print("Dont found stop nethod")

line = buffer[cline]
oline = cline
while re.match(r'^\t*},?',line) == None:
	vim.command('normal ]}')
	cline = window.cursor[0]-1

	if oline == cline:
		print("Dont found stop method")
		#return ""
		break

	oline = cline
	line = buffer[cline]

eline = cline
vim.command('let eline = ' + str(eline+1))
EOF
let msg = getline(1) . "\n". join(getline(sline,eline),"\n")
return msg
endfunction

function! VectorHello()
	let str = 'print "hello"'
	call VectorSend(g:vector_ip, g:vector_port, str)
endfunction

function! VectorSend(ip, port, msg)
python3 << EOF
import vim
import socket

ip = vim.eval("a:ip")
port = int(vim.eval("a:port"))
msg = vim.eval("a:msg")

sock = socket.socket()
sock.connect((ip, port))
sock.send(msg.encode("utf-8") + b'\n# TCP-END\n')
sock.close
EOF
endfunction

function! VectorPrint(ip, port, msg)
	echom a:ip
	echom a:port
	echom a:msg
endfunction

