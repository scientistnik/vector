import neovim

import re
import socket

@neovim.plugin
class Vector:

	def __init__(self,vim):
		self.vim = vim
		self.ip = "192.168.3.116"
		self.port = "20000"

	@neovim.function("VectorSetVar", sync=True)
	def setvar(self, args):
		if args[0] == "windows":
			self.ip = "192.168.3.116"
			self.port = "20000"
		else:
			self.ip = "192.168.3.115"
			self.port = "20000"

	def send(self, message):
		sock = socket.socket()
		sock.settimeout(1)
		sock.connect((self.ip,int(self.port)))
		sock.settimeout(None)
		sock.send(message.encode("utf-8") + b'\n# TCP-END\n')
		sock.close

	@neovim.function("Vector", sync=True)
	def vector(self, args):
		if args[0] == "all":
			self.vim.command("echom 'all'")
		else:
			msg = self.get_method()
			if msg != None:
				self.send(msg)
				self.vim.command("echom 'send to vec'")
			else:
				self.vim.command("echom 'error'")

	def get_method(self):
		buffer = self.vim.current.buffer
		window = self.vim.current.window

		cursor = window.cursor

		self.vim.command('normal [{')
		cline = window.cursor[0]-1

		line = buffer[cline]

		oline = cline
		while re.match( r'^\t*(methods)? *:.*=> %q{',line) == None:
			self.vim.command('normal [{')
			cline = window.cursor[0]-1

			if oline == cline:
				print("Dont found start method")
				return None
			oline = cline

			line = buffer[cline]

		sline = cline

		self.vim.command('normal ]}')
		cline = window.cursor[0]-1
		if cline == oline:
			print("Dont found stop method")
			return None

		line = buffer[cline]
		oline = cline
		while re.match(r'^\t*},?',line) == None:
			self.vim.command('normal ]}')
			cline = window.cursor[0]-1

			if oline == cline:
				print("Dont found stop method")
				return None

			oline = cline
			line = buffer[cline]

		eline = cline

		window.cursor = cursor

		result = buffer[0].replace('.create','.modify',1) + '\n'
		if re.match(r'\t*methods.*',buffer[sline]) == None:
			result += "\tmethods " + buffer[sline].replace('\t','') + '\n'
		else:
			result += buffer[sline] + '\n'

		result += '\n'.join(buffer[sline+1:eline]) + '\n'

		result +=  buffer[eline].replace(',','',1)
		return result
