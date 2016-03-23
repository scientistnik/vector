import sublime, sublime_plugin

class VectorCommand(sublime_plugin.TextCommand):
	FIFO_FILE_NAME = "/home/nozdrin/workspace/rvec/server/bin/fifo"
	TEMP_FILE = "/home/nozdrin/workspace/rvec/temp"

	def run(self, edit):
		str = self.view.substr(self.view.line(1))

		#view = self.window.active_view()
		name_file = self.view.window().active_view().file_name()
		if str.find("Module.") != -1:
			body = self.build_module_str()
			if body == None:
				return
			name_file = self.TEMP_FILE
			f = open(name_file,'w')
			f.write(body)
			f.close
		fifo = open(self.FIFO_FILE_NAME,'w+',0)
		fifo.write("User::Git.load_in \"" + name_file + "\"\n")
		fifo.flush
		fifo.close

	def build_module_str(self):
		str = self.view.substr(self.view.line(1)).replace(".create",".modify") + "\n"
		# change .create on .modify

		pos = self.view.line(self.view.sel()[0])

		txt = self.view.substr(pos)
		cur = pos.begin()
		while txt.find('%q{') == -1:
			if cur == 0:
				print "ERROR"
				return None
			cur = pos.begin()-1
			pos = self.view.line(sublime.Region(cur,cur))
			txt = self.view.substr(pos)
		first_pos = pos

		if self.view.substr(first_pos).find("methods ") == -1:
			str += "\tmethods"

		last_pos = self.view.line(self.view.find('^\t*\},?$',pos.begin()))
		if last_pos == None:
			print "ERROR"
			return None
		str += self.view.substr(sublime.Region(first_pos.begin(),last_pos.end()))
		if str[-1] == ",":
			str = str[:-1]
		str += "\nend"
		return str

