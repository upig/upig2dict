#!/usr/bin/env ruby

require 'active_record'
require 'yaml'

class DataBase1 < ActiveRecord::Base
  establish_connection :adapter=>'sqlite3', :database=>'inflections.sqlite3'
end
class DataBase2 < ActiveRecord::Base
  establish_connection :adapter=>'sqlite3', :database=>'inflections_new.sqlite3'
end

class Mydb < DataBase1
  set_table_name 'items'
end
class Mydbout < DataBase2
  set_table_name 'items'
end


@inf_has = Hash.new
Mydb.transaction do
Mydbout.transaction do
    Mydb.find(:all).each do |item| 
      @inf_has[item.name.downcase] = true

      next if item.inflection == nil
      item.inflection.downcase!
      item.inflection.gsub!(/[^\s]#{item.name}[$\s]/i, '')
      item.inflection.strip!
      next if item.inflection == ''
      next if item.inflection.include?('"')
      next if item.inflection.include?('.')
      next if item.inflection.include?('-')
      next if item.inflection.include?('\'')
      next if item.inflection.include?('/')
      next if item.inflection.include?('\\')

      arr = item.inflection.split(' ')
      arr.uniq!
      arr.each do |inf|
        inf.replace('') if @inf_has.has_key?(inf)
        @inf_has[inf]=true
      end
      newinf = arr.join(' ')
      next if newinf.strip == ''
      newinf.strip!

      db = Mydbout.new
      db.name = item.name
      db.inflection = newinf + ' '
      db.save
    end 
end
end
