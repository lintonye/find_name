#!/usr/bin/ruby
#
require './findname.rb'
require 'pathname'

def save(params, name)
  io = params[name].first
  out_dir = Pathname.new '.'
  File.open out_dir+io.original_filename, 'w' do |f| 
    f<<io.read
  end
end

puts "Content-Type: text/html"
puts
puts "<html>"
puts "<body>"
puts "<h1>Hello Ruby!</h1>"
puts "</body>"
puts "</html>"
=begin
cgi = CGI.new
params = cgi.params

master_file = save params, 'master'
input_file = save params, 'input'
run_findname master_file, input_file

cgi.header('Content-Disposition' => 'attachment;filename=output.csv')
cgi.out 'application/zip' { File.open 'output.csv', 'r'}

=end
