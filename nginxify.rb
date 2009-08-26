require 'lib/nginxify.rb'
require 'pathname'

input_folder = "/Users/rickashley/conf/"
output_folder = "/Users/rickashley/nginx"

nginx = Nginxify::Base.new(input_folder, output_folder)

nginx.convert!
