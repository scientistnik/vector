function! Vector()
ruby << EOF
	cbuf = VIM::Buffer.current

	def Build_module_str cbuf
		str = String.new(cbuf[1] + "\n")
		str.sub!(/\.create/,".modify")

		start_cur = Vim::Window.current.cursor
		VIM.command("normal [{")
		b_line = cbuf.line_number
		txt = cbuf.line
		while !txt.match(/^\t*.*:.*=>.*%q{.*$/) do
			VIM.command("normal [{")
			c_line = cbuf.line_number

			if c_line == b_line
				print "ERR"
				return nil
			end
			txt = cbuf[c_line]
			b_line = c_line
		end

		VIM.command("normal j]}")
		e_line = cbuf.line_number
		txt = cbuf.line
		while !txt.match(/\t*},?$/) do
			VIM.commad("normal ]}")
			c_line = cbuf.line_number

			if c_line == e_line
				print "ERR"
				return nil
			end
			txt = cbuf[c_line]
			e_line = c_line
		end
		Vim::Window.current.cursor = start_cur
		
		if !cbuf[b_line].include?("methods")
			str << "\tmethods" + cbuf[b_line].sub("\t","") + "\n"
			b_line += 1
		end
		while b_line != e_line do
			str << cbuf[b_line] +"\n"
			b_line += 1
		end
		str << cbuf[b_line].sub(",","") + "\n"
		str << cbuf[cbuf.count]

		str
	end

	if cbuf[1].include?("Module.")
		body = Build_module_str cbuf
		return if !body
		
		name = "#{Dir.pwd}/temp"

		file = File.new(name, "w")
		file << body
		file.close
	else
		name = cbuf.name
	end

	fifo_dir="/home/nozdrin/workspace/rvec/server/bin"

	pipe = open("#{fifo_dir}/fifo","w+")
	pipe.puts %Q{User::Git.load_in "#{name}"}
	pipe.flush
	pipe.close

	print "User::Git.load_in ./temp"
EOF
endfunction

function! VectorUpdate()
ruby << EOF
	fifo_dir="/home/nozdrin/workspace/rvec/server/bin"

	pipe = open("#{fifo_dir}/fifo","w+")
	pipe.puts %Q{User::Git.load_out "#{Dir.pwd}"}
	pipe.flush
	pipe.close
	print "User::Git.load_out ./"
EOF
endfunction

function! VectorTest()
ruby << EOF
	fifo_dir="/home/nozdrin/workspace/rvec/server/bin"

	pipe = open("#{fifo_dir}/fifo","w+")
	pipe.puts %Q{puts "Hello, World"}
	pipe.flush
	pipe.close
	print "send HELLO"
EOF
endfunction

function! VectorWork()
	e 05_Modules/M_Caption_object_model.rb
	e 05_Modules/M_Caption_TTO.rb
	e 05_Modules/M_Caption_variables.rb
	e 05_Modules/M_Property.rb
	e 05_Modules/M_Technology_object.rb
	echom "OK"
	b4
	new
	b3
	vne
	b2
	wincmd j
	vne
	b5
	vne
	b1
endfunction

