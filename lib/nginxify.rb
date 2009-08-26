class Nginxify
	class Nginxify::Base
		attr_accessor :input_folder, :output_folder
	
		def initialize(input_folder, output_folder)
			raise "Don't set the input_folder and output_folder to the same folder please." if input_folder == output_folder
			puts("Getting files from #{input_folder}")
			@input_folder = input_folder
			puts("Saving files to #{output_folder}")
			@output_folder = output_folder
		end
	
		def convert!
			Dir.glob("#{@input_folder}/*").each do |file|
				a = Nginxify::Worker.new(file, @output_folder)
				a.convert
			end
		end
	end

	class Nginxify::Worker 
		attr_accessor :file_handle
		attr_accessor :file_lines
		attr_accessor :output_folder
	
		$SETTINGS = {
			"ServerName" => "server_name",
			"DocumentRoot" => "root",
			"RailsBaseURI" => "passenger_base_uri",
			"RackBaseURI" => "passenger_base_uri",
			"PassengerAppRoot" => "passenger_root",
			"PassengerUseGlobalQueue" => "passenger_use_global_queue",
			"ServerAlias" => "server_name",
			"RailsEnv" => "rails_env"
		}
	
		def initialize(file, output_folder)
			@file_handle = File.open(file, "r")
			@file_name = Pathname.new(file).basename
			@port = ""
			@file_lines = []
			@output_folder = output_folder
		end
	
		def convert
			@file_handle.each do |line|
				self.process(line)
			end
			write_file
		end
	
		def write_line(line, start_or_end = false)
			if start_or_end
				file_lines << "#{line}\n"
			else
				file_lines << "  #{line};\n"
			end
		end
	
		def process(line)
			if line.include?("<VirtualHost")
					write_line("server {",true)
					port = line.scan(/\d+/)
					if port && port[0]
						if port.size > 1
							write_line("listen #{port[0..3].join(".")}")
						else
							write_line("listen #{port[0]}")
						end
					else
						write_line("listen *")
					end
				end
				if line.include?("</VirtualHost>")
					write_line("passenger_enabled on")
					write_line("}", true)
				end
			$SETTINGS.each_key do |x|
					if line.include?(x)
		 				write_line("#{$SETTINGS[x]} #{line.split(" ")[1]}") 
					end
			end
		end
	
		def write_file
			puts("Writing to #{@output_folder}/#{@file_name}.nginx")
			file = File.open("#{@output_folder}/#{@file_name}.nginx", "w+")
			file_lines.each do |line|
				file << line
			end
			file.close
		end
	end
end