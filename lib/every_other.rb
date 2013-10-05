module HungerGames
	#	alternate hunt / slack
	class EveryOther < Player
		def initialize
			@next = 'h'
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

		private

		def choice
			@next = (@next == 'h') ? 's' : 'h'
		end
	end
end
