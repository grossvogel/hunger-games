module HungerGames
	#	always cooperate
	class Dove < Player
		def hunt_choices(round_number, current_food, current_reputation, m, other_player_reputations)
			hunts = other_player_reputations.map { |r| 'h' }
		end

		def hunt_outcomes(food_earnings)
			#	ignore results
		end

		def round_end(award, m, number_hunters)
			#	ignore results
		end
	end
end
