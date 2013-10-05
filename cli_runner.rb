require "curses"
require "./lib/bootstrap.rb"
include Curses
include HungerGames

def draw_graph(players, round, left_column_width)
	width = cols - left_column_width
	player_no = 0
	max = players.map { |id,player| player[:food] }.max
	increment = max / width + 1

	players.each do |id, player|
		setpos(player_no, 0)
		addstr ((id.to_s + ":" + player[:player].to_s)[0..(left_column_width-2)])
		setpos(player_no, left_column_width - 1)
		bar_length = player[:food] / increment
		bar_length = bar_length < 0 ? 0 : bar_length
		padding = width - bar_length
		padding = padding < 0 ? 0 : padding
		bar = "|" << "=" * bar_length << " " * padding
		addstr(bar)
		
		player_no += 1
	end
	setpos(players.length,0)
	addstr("-" * cols)


	setpos(players.length + 1, 0)
	addstr("Round #{round}")

	max_score_label = "Current Winner's Food: "
	setpos(players.length + 1, cols - max_score_label.length - 15)
	addstr(max_score_label + "%-15d" % max.to_s)
	refresh
end


arena = Arena.new(100000, 0.05)
10.times do |i|
	arena << RandomPlayerPlus.new(rand() * 0.8 + 0.1)
end
arena << Hawk.new
arena << Dove.new
arena << EveryOther.new
arena << Mirror.new
arena << SmartyPants.new(0.0, 0.1)
arena << StraightRep.new(rand() * 0.8 + 0.1)


init_screen
begin
	crmode

	winner = arena.run { |players, round|
		if round % 10 == 0 || arena.players_remaining < 3 || round > arena.round_end_threshold
			draw_graph(players, round, 20)
		end
	}

	draw_graph(arena.players, arena.round, 20)

	setpos(arena.players.length + 4, 0)
	addstr("the game finished after round #{arena.round}")
	setpos(arena.players.length + 5, 0)
	addstr("the winner was #{winner.inspect}")

	setpos((lines - 5) / 2, (cols - 10) / 2)
	addstr("Hit any key")
	getch
	refresh
ensure
	close_screen
end

