#coding:utf-8

@same = Hash.new

str1 = IO.read('sameword.txt')
str1.split(/\nQ: /).each {|str|
  next if str==""
  str.gsub!('<br/>', '@CRLF')
  str =~/(.*?)\nA:\s(.*)/
  @same[$1] = $2.strip
}

puts 'parse done'

File.open('xiang_add_same.dict', 'w:utf-8') do |fout|
  File.open('xiang.dict', 'r:utf-8').each_line do |line|
    line =~/^(.*?)\s/
    word = $1
    if @same.has_key?(word)
      line.sub!(/@CRLF$/, '')
      fout.puts line.strip + @same[word] + '@CRLF'
    else
      fout.puts line
    end
  end
end


