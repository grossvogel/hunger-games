#	load everything in lib
lib = File.expand_path(File.dirname(__FILE__))
$: << lib
Dir[lib + "/*.rb"].each { |file| require file }

