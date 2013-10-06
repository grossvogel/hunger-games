require "./lib/bootstrap.rb"
include HungerGames

class HungerGamesWebUI < WebsocketGui::Base

	def initialize(options = {})
		@hg_config = {
			tick_interval: 0.1,
			rounds_per_iteration: 200,
			round_end_threshold: 100000,
			round_end_chance: 0.05,
		}
		@running = false
		@players = []

		@hg_config.merge! options
		super(tick_interval: @hg_config[:tick_interval])
	end

	view :web_client

	on_tick do |connected|
		if connected && @running
			unless @winner
				@winner = @arena.run(@hg_config[:rounds_per_iteration])
				update_client
			end
		end
	end

	on_socket_open do |handshake|
		@players = []
		all_players = {
			all_players: HungerGames.all_player_classes
		}
		socket_send all_players.to_json
	end

	on_start do |params|
		return if @players.empty?
		@running = true
		@hg_config[:rounds_per_iteration] = params['rounds_per_iteration'].to_i
		@hg_config[:round_end_threshold] = params['round_end_threshold'].to_i
		arena_init
	end

	on_add_player do |params|
		@players << params['player_name']
	end

	on_remove_player do |params|
		@players.delete params['player_name']
	end

	private

	def arena_init
		@winner = nil
		@arena = Arena.new(@hg_config[:round_end_threshold], @hg_config[:round_end_chance])
		HungerGames.player_instances(@players).each do |player|
			@arena << player
		end
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

app = HungerGamesWebUI.new()
app.run!

