function! VectorSerVar(os)
	if a:os == "windows"
		let g:vector_ip = "192.168.3.116"
	else
		let g:vector_ip = "192.168.3.115"
	endif
	let g:vector_port = "20000"
	echom g:vector_ip 
	echom g:vector_port
endfunction

function! Vector()
	call VectorSend(g:vector_ip, g:vector_port, join(getline(1,'$'), "\n"))
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

