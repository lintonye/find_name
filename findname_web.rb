#!/usr/bin/ruby
#
require './findname.rb'
require 'pathname'
require 'cgi'

include Findname
API = true
OUT_DIR = Pathname.new '/tmp'
def save(params, name)
  io = params[name].first
  path = OUT_DIR+io.original_filename
  File.open path, 'w' do |f| 
    f<<io.read
  end
  path
end

cgi = CGI.new
params = cgi.params
master_file = save params, 'master'
input_file = save params, 'input'

#master_file = '/tmp/master.csv'
#input_file = '/tmp/input.csv'

output_path = OUT_DIR + 'output.csv'
Findname.run master_file, input_file, output_path.to_s
output = File.open(output_path, 'r').read

cgi.out "Content-Type" => 'application/zip',
   "content-disposition" => "attachment; filename=output.csv"  do 
  output
end

