"""
--- Day 20: Race Condition ---

The Historians are quite pixelated again. This time, a massive, black building 
looms over you - you're right outside the CPU!

While The Historians get to work
, a nearby program sees that you're idle and challenges you to a race. 
Apparently, you've arrived just in time for the frequently-held race condition festival!

The race takes place on a particularly long and twisting code path; programs 
compete to see who can finish in the fewest picoseconds. The winner even gets 
their very own mutex!

They hand you a map of the racetrack (your puzzle input). For example:

###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############

The map consists of track (.) - including the start (S) and end (E) positions (
both of which also count as track) - and walls (#).

When a program runs 
through the racetrack, it starts at the start position. Then, it is allowed to 
move up, down, left, or right; each such move takes 1 picosecond. The goal is 
to reach the end position as quickly as possible. In this example racetrack, 
the fastest time is 84 picoseconds.

Because there is only a single path from 
the start to the end and the programs all go the same speed, the races used to 
be pretty boring. To make things more interesting, they introduced a new rule 
to the races: programs are allowed to cheat.

The rules for cheating are very strict. Exactly once during a race, a program 
may disable collision for up to 2 picoseconds. This allows the program to pass 
through walls as if they were regular track. At the end of the cheat, the 
program must be back on normal track again; otherwise, it will receive a 
segmentation fault and get disqualified.

So, a program could complete the course in 72 picoseconds (saving 12 
picoseconds) by cheating for the two moves marked 1 and 2:

###############
#...#...12....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############

Or, a program could complete the course in 64 picoseconds (saving 20 
picoseconds) by cheating for the two moves marked 1 and 2:

###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...12..#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############

This cheat saves 38 picoseconds:

###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.####1##.###
#...###.2.#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############

This cheat saves 64 picoseconds and takes the program directly to the end:

###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..21...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############

Each cheat has a distinct start position (the position where the cheat is 
activated, just before the first move that is allowed to go through walls) and 
end position; cheats are uniquely identified by their start position and end 
position.

In this example, the total number of cheats (grouped by the amount of time 
they save) are as follows:

    There are 14 cheats that save 2 picoseconds.
    There are 14 cheats that save 4 picoseconds.
    There are 2 cheats that save 6 picoseconds.
    There are 4 cheats that save 8 picoseconds.
    There are 2 cheats that save 10 picoseconds.
    There are 3 cheats that save 12 picoseconds.
    There is one cheat that saves 20 picoseconds.
    There is one cheat that saves 36 picoseconds.
    There is one cheat that saves 38 picoseconds.
    There is one cheat that saves 40 picoseconds.
    There is one cheat that saves 64 picoseconds.

You aren't sure what the conditions of the racetrack will be like, so to give 
yourself as many options as possible, you'll need a list of the best cheats. 
How many cheats would save you at least 100 picoseconds?
"""

function load_map(file_path)
    """
    Load the data into a matrix
    """
    p_row   = readlines(file_path)
    pp_char = split.(p_row, "") 
    return hcat(pp_char ...)
end

function step(cord, direction)
    increment = [0, 0]
    
    if direction == 0
        increment = [-1, 0]
    elseif direction == 1
        increment = [0, -1]
    elseif direction == 2
        increment = [+1, 0]
    elseif direction == 3
        increment = [0, +1]
    else
        error("Invalid direction: $direction")
    end
    
    new_cord = cord .+ increment

    return new_cord
end

function create_cost_map(race_map)
    cost_race_map = fill(Inf, size(race_map)...)  # Initialize the cost map with zeros (floating-point)
    E_cord = collect(Tuple(findfirst(x-> x == "E", race_map)))

    cost_race_map[E_cord[1], E_cord[2]] = 0
    p_cord_active = [E_cord]
    p_cord_traced = [E_cord]

    cost = 1
    while length(p_cord_active) > 0
        # println(p_cord_active)
        p_cord_active_new = []
        for cord in p_cord_active
            for direction in (0:3)
                cord_new = step(cord, direction)        
                if race_map[cord_new[1], cord_new[2]] != "#" && !(cord_new in p_cord_traced)
                    push!(p_cord_traced, cord_new)
                    push!(p_cord_active_new, cord_new)
                    cost_race_map[cord_new[1], cord_new[2]] = cost
                end
            end
        end
        cost += 1
        p_cord_active = p_cord_active_new
    end

    cost_race_map[race_map .== "#"] .= Inf        # Set entries with "#" in `map` to `Inf`
    return cost_race_map
end

function print_map(race_map)
    for y in (1:size(race_map, 2))
        row = join([x == "." ? " " : x for x in race_map[:, y]])
        println(row)
    end
end

# Maybe it is written and I am just stupid, but I want to know 
# If the map is what i would name "sequential" 
# namely every free spot of the map is reached at some point 
# by only one path, hence, there is only one single path 
# that connects S and E 
# # Turns out it actually is! the problem is now much simpler
function is_sequential(cost_race_map)
    A = filter(x -> x != Inf, cost_race_map)
    B = unique(A)
    return A == B
end

function get_manhattan_dist(cord1, cord2)
    return abs(cord1[1] - cord2[1]) + abs(cord1[2] - cord2[2]) 
end

function get_p_shortcut_time(race_map, cheat_time)
    cost_race_map = create_cost_map(race_map)
    
    p_shortcut = []
    for x1 in range(2, size(race_map, 1) - 1)
        for y1 in range(2, size(race_map, 2) - 1)
            if race_map[x1, y1] != "#"
                for x2 in range(2, size(race_map, 1) - 1)
                    for y2 in range(2, size(race_map, 2) - 1)
                        if race_map[x2, y2] != "#"
                            dist_phase = get_manhattan_dist([x2, y2], [x1, y1])
                            dist_fair  = cost_race_map[x2, y2] - cost_race_map[x1, y1]
                            if dist_fair > 0 && dist_phase <= cheat_time && dist_fair - dist_phase > 0
                                # println(dist_fair, " ", dist_phase)
                                push!(p_shortcut, Int(dist_fair - dist_phase))
                                # sleep(1)
                            end
                        end
                    end
                end
            end
        end
    end
    return p_shortcut
end

function print_results(race_map, cheat_time)
    p_shortcut_time = get_p_shortcut_time(race_map, cheat_time)

    for shortcut in sort(unique(p_shortcut_time))
        n_cheat = count(x -> x == shortcut, p_shortcut_time)
        println(" - There are $n_cheat cheats that save $shortcut picoseconds")
    end
end

file_path = "./data/day20.txt"
race_map = load_map(file_path)
cost_map = create_cost_map(race_map)

p_shortcut_time = get_p_shortcut_time(race_map, 2)
solution = count(x -> x > 99, p_shortcut_time)
println("Solution is $solution")

"""
--- Part Two ---

The programs seem perplexed by your list of cheats. Apparently, the two-
picosecond cheating rule was deprecated several milliseconds ago! The latest 
version of the cheating rule permits a single cheat that instead lasts at most 
20 picoseconds.

Now, in addition to all the cheats that were possible in just two picoseconds, 
many more cheats are possible. This six-picosecond cheat saves 76 picoseconds:

###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#1#####.#.#.###
#2#####.#.#...#
#3#####.#.###.#
#456.E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############

Because this cheat has the same start and end positions as the one above, it's 
the same cheat, even though the path taken during the cheat is different:

###############
#...#...#.....#
#.#.#.#.#.###.#
#S12..#.#.#...#
###3###.#.#.###
###4###.#.#...#
###5###.#.###.#
###6.E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############

Cheats don't need to use all 20 picoseconds; cheats can last any amount of 
time up to and including 20 picoseconds (but can still only end when the 
program is on normal track). Any cheat time not used is lost; it can't be 
saved for another cheat later.

You'll still need a list of the best cheats, but now there are even more to 
choose between. Here are the quantities of cheats in this example that save 50 
picoseconds or more:

    There are 32 cheats that save 50 picoseconds.
    There are 31 cheats that save 52 picoseconds.
    There are 29 cheats that save 54 picoseconds.
    There are 39 cheats that save 56 picoseconds.
    There are 25 cheats that save 58 picoseconds.
    There are 23 cheats that save 60 picoseconds.
    There are 20 cheats that save 62 picoseconds.
    There are 19 cheats that save 64 picoseconds.
    There are 12 cheats that save 66 picoseconds.
    There are 14 cheats that save 68 picoseconds.
    There are 12 cheats that save 70 picoseconds.
    There are 22 cheats that save 72 picoseconds.
    There are 4 cheats that save 74 picoseconds.
    There are 3 cheats that save 76 picoseconds.

Find the best cheats using the updated cheating rules. How many cheats would 
save you at least 100 picoseconds?
"""

p_shortcut_time = get_p_shortcut_time(race_map, 20)
solution = count(x -> x > 99, p_shortcut_time)
println("Solution is $solution")
