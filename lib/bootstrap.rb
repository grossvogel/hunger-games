#	get the websocket library
require "rubygems"
require "websocket-gui"
require "json"

#	load everything in lib
lib = File.expand_path(File.dirname(__FILE__))
$: << lib
Dir[lib + "/*.rb"].each { |file| require file }

