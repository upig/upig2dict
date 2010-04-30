# coding: utf-8
require 'active_record'
require 'yaml'

class DataBase1 < ActiveRecord::Base
  establish_connection :adapter=>'sqlite3', :database=>'inflections.sqlite3'
end

class Mydb < DataBase1
  set_table_name 'items'
end

input_file = ARGV[0] || "xiang.dict" 


get_inflections = lambda {|word|
  inflections = []
  word.strip!
  infItems =Mydb.find_all_by_name(word) 
  return nil if infItems==nil
  infItems.each {|item|
    inflections |=item.inflection.split(' ')
  }
  return inflections
}

HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;', ' '=>'&nbsp;', "\n"=>'<br/>' }


def h(s)
  s.to_s.gsub(/[&"><\n]/) { |special| HTML_ESCAPE[special] }
end


dic_header = <<'DIC EOF'
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title>Xiang's dictionary</title>
  </head>
  <body>
    <center>
      <hr />
      <font size="+4">Xiang's dictionary</font>
      <hr width="10%" />
        <!-- controls -->
        <center> 本词典是由网上收集到的资料整理而成，完全免费使用，如果有发现侵权的地方，请及时与我联系以便进行修正。如果有朋友知道开源的英汉词典，也可以与我联系。下一步我还想组织一个开源的英汉词典网站。 感谢orslane、pocketpc等网友。 <br /><br />
         祝福我的老婆和即将出生的小宝宝。<br />
         向为 2010年 长沙 <br />
         邮箱：31531640@qq.com <br />
         主页：http://17memo.com </center>
        <a onclick="index_search('dic')">Index</a><br />
      <hr />
    </center>
<mbp:pagebreak />

<!-- DICTIONARY ENTRIES -->
DIC EOF


dic_footer = <<'DIC FOOTER'
</body>
</html>
DIC FOOTER


dic_item = <<-'ITEM_TEXT'

<idx:entry name="dic"><idx:orth><%=h word_item[:word]%><%=infl_header%><% word_item[:inflections].each do |inflection|%><idx:iform value="<%=h inflection%>"/><% end %><%=infl_tail%></idx:orth><blockquote><%=h (word_item[:explanation]+"\n")%></blockquote></idx:entry><hr/>
ITEM_TEXT


require 'erb'
@dir = 'mobi/'
@word_list = Hash.new
@first_line = true
File.new(input_file, 'r:utf-8').each_line{|line|
  if @first_line 
    @first_line = false
    line = line [1..-1]
  end
  line =~ /(.*?)\t(.*?)\s+(.*)/u
  word_hash = {}
  word = $1
  word_hash[:word] = $2
  explanation = $3
  word_hash[:explanation] = ''
  explanation.gsub!(/@CRLFK\.K\..*?@CRLF/, '@CRLF') #只留下一种音标
  #explanation.gsub!(/^#{word_hash[:word]}\s*/, '') 
  explanation.gsub!(/@CRLFD\.J\./, '') #删除无聊的东西
  explanation.gsub!(/\s*@CRLF/, "\n") #换行符
  explanation.squeeze!
  explanation.strip!
  explanation.each_line {|line|
    word_hash[:explanation] += line
  }
  word_hash[:inflections] = get_inflections.call(word_hash[:word])
  if word_hash[:word]!=word
     word_hash[:inflections] |= [word.strip]
     #puts word + ' '+  word_hash[:word]
  end
  if @word_list.has_key?(word_hash[:word])
    word_hash[:inflections] |= (@word_list[word_hash[:word]])[:inflections]
    #puts word
  end
  @word_list[word_hash[:word]]= word_hash.clone
}

File.open("#{@dir}dic.html", 'w:utf-8') do |fp|
  dic_item.chomp!
  fp.print dic_header
  @word_list.values.each do |word_item|
    if word_item[:inflections].size>0 
      infl_header = '<idx:infl>'
      infl_tail ='</idx:infl>'
    else
      infl_header = ''
      infl_tail =''
    end
    
    fp.print ERB.new(dic_item).result(binding) 
  end 
  fp.print dic_footer
end

opf_text = <<-'OPF EOF'
<?xml version="1.0" encoding="utf-8"?>
<package unique-identifier="uid">
	<metadata>
		<dc-metadata xmlns:dc="http://purl.org/metadata/dublin_core" xmlns:oebpackage="http://openebook.org/namespaces/oeb-package/1.0/">
			<dc:Identifier id="uid">111111204</dc:Identifier>
			<dc:Title>Xiang's dictionary V4</dc:Title>
			<dc:Creator>17memo.com</dc:Creator>
			<dc:Date>03/30/2010</dc:Date>
			<dc:Copyrights>Xiang Wei</dc:Copyrights>
			
			<dc:Subject></dc:Subject>
			<dc:Language>en</dc:Language>
		</dc-metadata>
		<x-metadata>
			<DictionaryInLanguage>en</DictionaryInLanguage>
			<DictionaryOutLanguage>zh-cn</DictionaryOutLanguage>
		<EmbeddedCover>xw.JPG</EmbeddedCover></x-metadata>
	</metadata>
	<manifest>
		<item id="dic" href="dic.html" media-type="text/x-oeb1-document"/>
	</manifest>
	<spine>
		<itemref idref="dic"/>
	</spine>
	<tours>
	</tours>
	<guide>
	</guide>
</package>
OPF EOF

File.open("#{@dir}xiang.opf", 'w:utf-8') do |fp|
  opf_text.chomp!
  fp.print opf_text
end
