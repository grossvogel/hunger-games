#
#	Player interface:
#
module HungerGames
	class Player

		#	Given the round number, your current food, your current reputation, the extra hunt threshold m, 
		#	and an array of other player reputations, create an array (indexed just like other_player_reputations) 
		#	of 'h' or 's' indicating whether or not you want to hunt with the player at that index
		#	Note that other_player_reputations is shuffled each time, so you cannot maintain state 
		#	using the indices to identify other players
		def hunt_choices(round_number, current_food, current_reputation, m, other_player_reputations)
			raise NotImplementedError
		end

		#	After hunting each round, players get an opportunity to examine how things went. 
		#	the food_earnings array is indexed just like other_player_reputations 
		#	in this round's hunt_choices call and contains the net result of each hunt, 
		#	depending on how successfully you and your 'partner' hunted.
		def hunt_outcomes(food_earnings)
			raise NotImplementedError
		end

		#	At the very end of the round, each player is notified about the 
		#	overall group performance and the extra hunt bounty.
		def round_end(award, m, number_hunters)
			raise NotImplementedError
		end

		def to_s
			self.class.name.split('::').last
		end

		#	this is just a silly utility method used by some of the example players.
		def hunt_with_top_n(number_of_hunts, other_player_reputations)
			if number_of_hunts >= other_player_reputations.length
				hunts = other_player_reputations.map { |r| 'h' }
				return hunts
			end

			if number_of_hunts <= 0
				hunts = other_player_reputations.map { |r| 's' }
				return hunts
			end

			sorted = other_player_reputations.sort
			cutoff = sorted[sorted.length - number_of_hunts]
			hunts = []
			hunt_count = 0
			other_player_reputations.each_with_index do |r, index|
				hunts[index] = (r > cutoff ? 'h' : 's')
				hunt_count += 1 if r > cutoff
			end
			other_player_reputations.each_with_index do |r, index|
				if r == cutoff && hunt_count < number_of_hunts
					hunts[index] = 'h'
					hunt_count += 1
				end
			end
			
			hunts
		end
	end

	#	get an array of all loaded classes that are subclasses of Player
	def self.all_player_classes
		self.constants.select{ |c| self.const_get(c) < self::Player }
	end

	#	given an array of Player subclass names (as returned by all_player_classes),
	#	create an instance of each one and return them in an array
	#	if no array is passed, default to all
	def self.player_instances(player_classes = nil)
		player_classes ||= self.all_player_classes
		player_classes.map{ |c| HungerGames.const_get(c).new }
	end
end

