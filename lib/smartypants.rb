module HungerGames
	class SmartyPants < Player

		def initialize(rep_deviation = -0.1, dove_margin = 0.1)
			#	we try to maintain a rep that is this far from the average
			@rep_deviation = rep_deviation
			
			#	don't waste energy hunting with doves
			@dove_margin = dove_margin 
		end

		def hunt_choices(round_number, current_food, current_reputation, m, other_player_reputations)
			#	figure out how many people to hunt with to maintain our desired rep
			rep_total = other_player_reputations.inject(0){|sum, rep| sum + rep }
			rep_mean = rep_total / other_player_reputations.length
			hunt_count = ((rep_mean + @rep_deviation) * other_player_reputations.length).to_i
			
			#	filter out the doves
			dove_count = other_player_reputations.select {|r| r > 1 - @dove_margin }.length

			hunts = hunt_with_top_n(hunt_count + dove_count, other_player_reputations)
			other_player_reputations.each_with_index do |r, index|
				hunts[index] = 's' if r > 1 - @dove_margin
			end
			hunts
		end

		def hunt_outcomes(food_earnings)
			#	ignore results
		end

		def round_end(award, m, number_hunters)
			#	ignore results
		end
	end
end
