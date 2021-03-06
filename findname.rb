#!/usr/local/bin/ruby
# encoding: utf-8
#
module Findname
  class Entry
    attr_accessor :name, :keywords
    def initialize(name, keywords)
      @name = name
      @keywords = []
      keywords.each {|k| @keywords<<k.downcase}
    end

    def count_matches(n)
      hits = 0; distance = 0;
      phrases = n.split(/\s|-|\.|&|\//)
      phrases.each do |phrase|
        found = false; d=0;
        keywords.each do |kwd|
          if kwd.index(phrase)==0
            d = (kwd.length-phrase.length).abs
            found = true; break;
          end
        end    
        hits = hits+1 if found
        distance = distance+d if found
      end
      return [hits, distance]
    end
  end

  def self.find_in_dict(dict, name)
    results = []
    begin
      name = name.downcase
    rescue
      # Remove invalid chars according to http://stackoverflow.com/a/8873922/3973320
      name.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
      name.encode!('UTF-8', 'UTF-16')
      name = name.downcase
    end
    dict.each do |entry|
      hits = entry.count_matches(name)
      results<<[hits, entry] if hits[0]>0
    end
    return results
  end

  def self.run(dict_file, input_file, output_file_path='output.csv', debug=false, max_match=20)  
    # parse dict
    dict = []
    open(dict_file, "rb") do |lines|
      lines.each_line do |line|
        pair = line.split(",")
        dict << Entry.new(pair[1].strip, pair[0].split(" ")) if pair[1]!=nil
      end
    end

=begin
  dict.each do |entry|
    kwd = entry.keywords.join(",")
    puts "#{entry.name}: #{kwd}"
  end
=end

    # process input file
    inputs = []
    open(input_file, "r") do |lines|
      lines.each {|line| inputs<<line unless inputs.include?(line)}
    end

    output_file = open(output_file_path, "w");

    inputs.each do |line|
      results = find_in_dict(dict, line)
      results = results.sort{|a,b| [b[0][0], a[0][1]] <=> [a[0][0], b[0][1]]} 

      output = []
      output<<line.chop

      # puts "[#{line.chop}]"
      i=0
      results.each do |result|
        if debug
          output << "#{result[0][0]}-#{result[0][1]} #{result[1].name} KEYWORDS:[#{result[1].keywords.join(" ")}]"
        else
          output<<"#{result[1].name}"
        end
        i = i+1
        break if i>max_match
      end      

      output_file<<output.join(",")+"\n"
    end

    output_file.close
  end

  def self.preprocess(file)
    content = File.open(file, 'rb').read
    lines = content.gsub(/(\r\n)|(\r)/, "\n")
    File.open(file,'w').write(lines)
  end

  def self.cmd_line
    if ARGV.length<2 
      puts "Usage: findname <dictionary file> <input file> [-debug]"
      puts "Example: findname standard.csv input.csv"
    else
      dict_file = ARGV[0]
      input_file = ARGV[1]
      debug = ARGV[2]!=nil and ARGV[2].include?("-d")
      max_match = 20
      preprocess(dict_file)
      preprocess(input_file)
      run dict_file, input_file, 'output.csv', debug, max_match
    end
  end

  cmd_line unless defined?(API)
end


