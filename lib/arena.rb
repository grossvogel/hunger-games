# Initial state:
#	P is the number of remaining players at any time
#	Each player starts with 300(P- 1) units of food (P being the total number since we have not started)
#	Each player has an initial reputation of 0
#
# Game end:
#	The game is over in one of these cases:
#		* After a certain (large) number of rounds, there is a small
#			chance the game will end after each round 
#		* There is only one player left with food after any round
#	The winner is the person with the most food at the end of the game
#
# Rounds:
#	During each round, each player decides whether or not to 'hunt' with each
#	other remaining player. This is P - 1 hunt decisions for each player to make.
#
#	If you hunt, you expend 6 units of food. If you slack, you spend 2.
#	Hunt returns are as follows:
#		Both hunt: 12 food -> 6 food per person	-> both break even
#		One hunts: 6 food -> 3 food per person -> hunter loses 3, slacker gains 1
#		Both slack: 0 food -> 0 food per person -> both lose 2
#	
#	Reputation at any time is R = H / H + s (the portion of times you choose to hunt in the past)
#
#	Extra hunt bounty: each round, a random number 0 < m < P(P - 1) is chosen. If the total number
#	of hunt choices that round is >= m, then everyone gets an extra 2(P-1) units of food (2 per hunt)
#	after the round.
#
# Players must respond to hunt_choices to determine with whom to hunt. they should also implement hunt_outcomes and round_end,
#	which will be called to provide the player with more info, if they want to maintain some state
#

module HungerGames
	class Arena
		attr_reader :players, :round, :players_remaining, :round_end_threshold

		def initialize(round_end_threshold, round_end_prob)
			@players = {} 
			@round = 0
			@players_remaining = nil 
			@round_end_threshold, @round_end_prob = round_end_threshold, round_end_prob
		end

		def add_player(player)
			id = @players.length + 1
			@players[id] = {
				:id => id,
				:player => player,
				:reputation => 0,
				:food => nil,
				:hunts => 0,
				:slacks => 0,
			}
			set_initial_values
		end

		alias << add_player

		def run(max_rounds_to_run = nil)
			starting_round = @round
			done = false
			until done
				@round += 1
				done = run_round
				yield @players, @round if block_given?
				if !done && max_rounds_to_run && (@round - starting_round > max_rounds_to_run)
					return nil
				end
			end

			winner = nil
			winning_score = nil
			@players.each do |id, player|
				if winning_score.nil? or player[:food] > winning_score
					winner = player
					winning_score = player[:food]
				end
			end
			winner
		end

		private
		
		#	return TRUE if this is the last round
		def run_round
			m, random_end = set_up_round
			active_players = @players.select { |id, player| player[:food] > 0 }
			
			all_choices = Hash.new
			total_hunt_choices = 0
			active_players.each do |id, player|
				opponents = active_players.keys.shuffle
				reps = opponents.map {|opp_id| @players[opp_id][:reputation]}
				choices = player[:player].hunt_choices(@round, player[:food], player[:reputation], m, reps)
				all_choices[id] = Hash.new
				opponents.each_with_index do |opp_id, index|
					all_choices[id][opp_id] = choices[index]
					if choices[index] == 'h'
						@players[id][:hunts] += 1
						@players[id][:food] -= 6
						total_hunt_choices += 1
					else
						@players[id][:slacks] += 1
						@players[id][:food] -= 2
					end
				end
			end

			reward_hunt_bounties(all_choices)
			reward_extra_bounty(active_players, m, total_hunt_choices)
			set_players_remaining
			update_reputations	

			@players_remaining < 2 || random_end
		end

		def reward_hunt_bounties(choices)
			choices.each do |player_one_id, player_choices|
				bounties = []
				player_choices.each do |player_two_id, choice|
					food = 0
					food += 6 if choice == 'h'
					food += 6 if choices[player_two_id][player_one_id] == 'h'
					food /= 2
					bounties.push food
					@players[player_one_id][:food] += food
				end
				@players[player_one_id][:player].hunt_outcomes(bounties)
			end
		end

		def reward_extra_bounty(active_players, m, total_hunt_choices)
			award = total_hunt_choices >= m ? 2 * (active_players.length - 1) : 0
			active_players.each do |id, player|
				@players[id][:food] += award
				@players[id][:player].round_end(award, m, total_hunt_choices)
			end
		end

		def set_initial_values
			player_count = @players.length
			starting_food = 300 * (player_count - 1)
			@players.each do |id, player|
				player[:food] = starting_food
			end
			set_players_remaining
		end

		def set_players_remaining
			@players_remaining = @players.select {|key, player| player[:food] > 0 }.length 
		end
		
		def update_reputations
			@players.each do |id, player|
				player[:reputation] = player[:hunts].to_f / (player[:hunts] + player[:slacks])
			end
		end

		def set_up_round
			m = rand(@players_remaining * (@players_remaining - 1))
			ending = @round > @round_end_threshold && rand < @round_end_prob
			[m, ending]
		end

	end
end
