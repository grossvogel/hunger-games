module HungerGames
	#	If your rep is .35, then I'll hunt with you 35% of the time
	class Mirror < Player
		def hunt_choices(round_number, current_food, current_reputation, m, other_player_reputations)
			hunts = other_player_reputations.map { |r| choice(r) }
		end

		def hunt_outcomes(food_earnings)
			#	ignore results
		end

		def round_end(award, m, number_hunters)
			#	ignore results
		end

		private

		def choice(r)
			rand() <= r ? 'h' : 's'
		end
	end
end
