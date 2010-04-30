#!/usr/bin/env ruby

require 'active_record'
require 'yaml'

class DataBase1 < ActiveRecord::Base
  establish_connection :adapter=>'sqlite3', :database=>'inflections.sqlite3'
end

class Mydb < DataBase1
  set_table_name 'items'
end

Mydb.transaction  do 
  File.new('collins_inf.txt').each_line{|line|
    db = Mydb.new
    line =~ /^(.*?)\s.*?:\s(.*)$/
      db.name = $1
    next if db.name.include?('-')
    db.inflection = ""
    inflectStr = $2
    inflectStr.split(/(,|\|)/).each{ |str|
      #remove explanation
      str.gsub!(/\{.*?\}/,'')
      #remove split string
      str.gsub!(/(,|\||\s)/, '')
      #remove tag
      str.gsub!(/[~<!?]/, '')
      #remove number
      str.gsub!(/\d/, '')
      #remove white space
      str.strip!
      next if str.empty?
      next if db.name=~/#{str}/i
        db.inflection += str+ ' ' 
    }
    next if db.inflection == ""
    db.save
  }
end 
