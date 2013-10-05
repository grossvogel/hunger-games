module HungerGames
	#	hunt X% of the time, regardless of opponent behavior
	class RandomPlayer < Player
		def initialize(threshold = 0.5)
			@threshold = threshold
		end

		def hunt_choices(round_number, current_food, current_reputation, m, other_player_reputations)
			hunts = other_player_reputations.map { |r| choice }
		end

		def hunt_outcomes(food_earnings)
			#	ignore results
		end

		def round_end(award, m, number_hunters)
			#	ignore results
		end

		def to_s
			"Random:#{@threshold.round(2)}"
		end

		private

		def choice
			rand() <= @threshold ? 'h' : 's'
		end
	end
end
