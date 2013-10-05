module HungerGames
	#	hunt with the top X% of players 
	class RandomPlayerPlus < Player
		def initialize(threshold = 0.5)
			@threshold = threshold
		end

		def hunt_choices(round_number, current_food, current_reputation, m, other_player_reputations)
			hunt_count = 0
			other_player_reputations.length.times do |i|
				hunt_count += 1 if rand() <= @threshold
			end
			hunt_with_top_n(hunt_count, other_player_reputations)
		end

		def hunt_outcomes(food_earnings)
			#	ignore results
		end

		def round_end(award, m, number_hunters)
			#	ignore results
		end

		def to_s
			"Random+:#{@threshold.round(2)}"
		end
	end
end
