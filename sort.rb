
File.open('xiang_sort.dict', 'w:utf-8') do |fout|
  arr = Array.new
  File.open('xiang.dict', 'r:utf-8').each_line do |line|
    arr << line
  end
  puts 'read ready'
  arr.sort!
  puts 'sort ready'
  fout.print arr.join
end



