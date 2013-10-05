require 'json'
require "rubygems"
require "websocket-gui"
require "./lib/bootstrap.rb"
include HungerGames

class HungerGamesWebUI < WebsocketGui::Base

	def initialize(rounds_per_iteration = 100, iteration_delay = 0.1, &arena_init_block)
		super(tick_interval: iteration_delay)
		@rounds_per_iteration = rounds_per_iteration
		if block_given?
			@arena_init = arena_init_block
		else
			raise "When creating a new #{self.class.name}, you must provide a block to initialize your HungerGames::Arena"
		end
	end

	view :web_client

	on_tick do |connected|
		if connected
			unless @winner
				@winner = @arena.run(@rounds_per_iteration)
				update_client
			end
		end
	end

	on_socket_open do |handshake|
		puts "Client connected. Initializing the arena."
		arena_init
		raise "The block passed did not initialize an arena!" unless @arena.is_a?HungerGames::Arena
	end

	private

	def arena_init
		@arena = @arena_init.call
		@winner = nil
	end

	def update_client
		data = { 
			winner: nil,
			round: @arena.round,
			players: [],
			max_food: nil,
		}
		data[:winner] = player_as_json(@winner) if @winner
		@arena.players.each do |id, player|
			data[:players] << player_as_json(player)
			data[:max_food] = player[:food] if data[:max_food].nil? || player[:food] > data[:max_food] 
		end
		socket_send data.to_json
	end

	def player_as_json(player)
		data = player.dup
		data[:player] = data[:player].to_s
		data
	end
end

app = HungerGamesWebUI.new(300, 0.1) do
	arena = Arena.new(100000, 0.05)
	3.times do |i|
		arena << RandomPlayerPlus.new(rand() * 0.8 + 0.1)
	end
	3.times do |i|
		arena << StraightRep.new(rand() * 0.8 + 0.1)
	end
	arena << Hawk.new
	arena << Dove.new
	arena << EveryOther.new
	arena << Mirror.new
	arena << Climber.new
	arena << SmartyPants.new(0.0, 0.1)
	arena
end
app.run!

