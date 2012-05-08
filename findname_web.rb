#!/usr/bin/ruby

require_relative 'findname'
require 'pathname'

def save(params, name)
  io = params[name].first
  out_dir = Pathname.new '.'
  File.open out_dir+io.original_filename, 'w' {|f| f<<io.read}
end

cgi = CGI.new
params = cgi.params

master_file = save params, 'master'
input_file = save params, 'input'
run_findname master_file, input_file

cgi.header('Content-Disposition' => 'attachment;filename=output.csv')
cgi.out 'application/zip' { File.open 'output.csv', 'r'}

