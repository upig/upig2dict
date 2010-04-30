#coding:utf-8
#
#


str1 = IO.read('21cen_wordlist.txt')
arr = str1.split("\n")
puts 'merge'
str2 =  IO.read('collins_wordlist.txt')
arr |= str2.split("\n")

File.open('merg_wordlist.txt', 'w') do |fout|
  fout.puts arr.join("\n")
end



