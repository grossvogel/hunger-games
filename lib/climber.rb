module HungerGames
	#	only hunt with players with a rep at least as good as mine
	class Climber < Player
		def hunt_choices(round_number, current_food, current_reputation, m, other_player_reputations)
			hunts = other_player_reputations.map { |r| choice(r, current_reputation) }
		end

		def hunt_outcomes(food_earnings)
			#	ignore results
		end

		def round_end(award, m, number_hunters)
			#	ignore results
		end

		private

		def choice(other_rep, my_rep)
			other_rep >= my_rep ? 'h' : 's'
		end
	end
end
