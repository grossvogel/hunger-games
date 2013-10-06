module HungerGames
	#	hunt with everybody who meets a fixed rep threshold
	class StraightRep < Player
		def initialize(threshold = nil)
			@threshold = threshold || (rand() * 0.7 + 0.15)
		end

		def hunt_choices(round_number, current_food, current_reputation, m, other_player_reputations)
			hunts = other_player_reputations.map { |r| choice(r) }
		end

		def hunt_outcomes(food_earnings)
			#	ignore results
		end

		def round_end(award, m, number_hunters)
			#	ignore results
		end

		def to_s
			"StraightRep:#{@threshold.round(2)}"
		end

		private

		def choice(opponent_rep)
			opponent_rep > @threshold ? 'h' : 's'
		end
	end
end
