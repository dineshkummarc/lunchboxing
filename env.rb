require 'rubygems'
require 'bundler/setup'
require 'data_mapper'
require 'dm-sqlite-adapter'
require './models/location'
require './models/user'
require './models/list'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db")

DataMapper.finalize
