mkdir mobi
copy mobi_bare mobi\
ruby gen_mobi_project.rb xiang.dict
kindlegen.exe mobi\xiang.opf
copy mobi\xiang.mobi
pause