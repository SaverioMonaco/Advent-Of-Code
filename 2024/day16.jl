"""
--- Day 16: Reindeer Maze ---

It's time again for the Reindeer Olympics! This year, the big event is the 
Reindeer Maze, where the Reindeer compete for the lowest score.

You and The Historians arrive to search for the Chief right as the event is 
about to start. It wouldn't hurt to watch a little, right?

The Reindeer start on the Start Tile (marked S) facing East and need to reach 
the End Tile (marked E). They can move forward one tile at a time (increasing 
their score by 1 point), but never into a wall (#). They can also rotate 
clockwise or counterclockwise 90 degrees at a time (increasing their score by 
1000 points).

To figure out the best place to sit, you start by grabbing a map (your puzzle 
input) from a nearby kiosk. For example:

###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############

There are many paths through this maze, but taking any of the best paths would 
incur a score of only 7036. This can be achieved by taking a total of 36 steps 
forward and turning 90 degrees a total of 7 times:


###############
#.......#....E#
#.#.###.#.###^#
#.....#.#...#^#
#.###.#####.#^#
#.#.#.......#^#
#.#.#####.###^#
#..>>>>>>>>v#^#
###^#.#####v#^#
#>>^#.....#v#^#
#^#.#.###.#v#^#
#^....#...#v#^#
#^###.#.#.#v#^#
#S..#.....#>>^#
###############

Here's a second example:

#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################

In this maze, the best paths cost 11048 points; following one such path would 
look like this:

#################
#...#...#...#..E#
#.#.#.#.#.#.#.#^#
#.#.#.#...#...#^#
#.#.#.#.###.#.#^#
#>>v#.#.#.....#^#
#^#v#.#.#.#####^#
#^#v..#.#.#>>>>^#
#^#v#####.#^###.#
#^#v#..>>>>^#...#
#^#v###^#####.###
#^#v#>>^#.....#.#
#^#v#^#####.###.#
#^#v#^........#.#
#^#v#^#########.#
#S#>>^..........#
#################

Note that the path shown above includes one 90 degree turn as the very first 
move, rotating the Reindeer from facing East to facing North.

Analyze your map carefully. What is the lowest score a Reindeer could possibly 
get?
"""

function load(file_path)
    map = hcat(split.(readlines(file_path), "") ...)
    return map
end

function print_map(map, reindeer)
    new_map = copy(map)
    for cord in reindeer.p_cord
        new_map[cord[1], cord[2]] = "@"
    end
    for y in (1:size(new_map, 2))
        row = join([x == "." ? " " : x for x in new_map[:, y]])
        println(row)
    end
end

# path will be a list of int: 0 ... 3 are the directions > ^ < v and 4 is a 
# counterclockwise rotation
mutable struct Reindeer
    p_cord
    direction
    tot_cost
end

function get_cord_forward(reindeer)
    if reindeer.direction == 0
        increment = [+1, 0]
    elseif reindeer.direction == 1
        increment = [0, -1]
    elseif reindeer.direction == 2
        increment = [-1, 0]
    elseif reindeer.direction == 3
        increment = [0, +1]
    end
        
    return reindeer.p_cord[end] .+ increment, reindeer.direction, reindeer.tot_cost + 1
end

function get_cord_right(reindeer)
    if reindeer.direction == 0
        increment = [0, +1]
    elseif reindeer.direction == 1
        increment = [+1, 0]
    elseif reindeer.direction == 2
        increment = [0, -1]
    elseif reindeer.direction == 3
        increment = [-1, 0]
    end
        
    return reindeer.p_cord[end] .+ increment, (reindeer.direction+3)%4, reindeer.tot_cost + 1000 + 1
end

function get_cord_left(reindeer)
    if reindeer.direction == 0
        increment = [0, -1]
    elseif reindeer.direction == 1
        increment = [-1, 0]
    elseif reindeer.direction == 2
        increment = [0, +1]
    elseif reindeer.direction == 3
        increment = [+1, 0]
    end

    return reindeer.p_cord[end] .+ increment, (reindeer.direction+1)%4, reindeer.tot_cost + 1000 + 1
end


function find_paths(map)
    S_cord = collect(Tuple(findfirst(x-> x == "S", map)))
    E_cord = collect(Tuple(findfirst(x-> x == "E", map)))
    
    p_reindeer = [Reindeer([S_cord], 0, 0)]    
    p_func_step = [get_cord_left, get_cord_right, get_cord_forward]

    p_reindeer_successfull = []    
    map_cost = fill(149492, size(map)...)
    while(length(p_reindeer)) > 0
        # println(length(p_reindeer))
        # at each step the reindeer can go either forward, left or right
        p_new_reindeer = []
        for reindeer in p_reindeer
            for func_step in p_func_step
                (new_cord, new_dir, new_cost) = func_step(reindeer)
                # The idea is that if you already have a Reindeer that 
                # got to this point at a lower cost, you might want to
                # discard the current reindeer
                if new_cost <= map_cost[new_cord[1], new_cord[2]]
                    map_cost[new_cord[1], new_cord[2]] = new_cost
                    if new_cord == E_cord
                        new_p_cord = vcat(reindeer.p_cord, [new_cord])
                        new_reindeer = Reindeer(new_p_cord, new_dir, new_cost)
                        push!(p_reindeer_successfull, new_reindeer)
                    elseif map[new_cord[1], new_cord[2]] == "." && !(new_cord in reindeer.p_cord)
                        new_p_cord = vcat(reindeer.p_cord, [new_cord])
                        new_reindeer = Reindeer(new_p_cord, new_dir, new_cost)
                        push!(p_new_reindeer, new_reindeer)
                    end
                end
            end
        end
        p_reindeer = p_new_reindeer
    end
    return p_reindeer_successfull
end

file_path = "./data/day16.txt"
map = load(file_path)
p_reindeer = find_paths(map)
cost_p_reindeer = [r.tot_cost for r in p_reindeer]
min_cost = minimum(cost_p_reindeer)
println("Minimum cost: $min_cost")

"""
--- Part Two ---

Now that you know what the best paths look like, you can figure out the best 
spot to sit.

Every non-wall tile (S, ., or E) is equipped with places to sit along the 
edges of the tile. While determining which of these tiles would be the best 
spot to sit depends on a whole bunch of factors (how comfortable the seats are
, how far away the bathrooms are, whether there's a pillar blocking your view, 
etc.), the most important factor is whether the tile is on one of the best 
paths through the maze. If you sit somewhere else, you'd miss all the action!

So, you'll need to determine which tiles are part of any best path through the 
maze, including the S and E tiles.

In the first example, there are 45 tiles (marked O) that are part of at least 
one of the various best paths through the maze:

###############
#.......#....O#
#.#.###.#.###O#
#.....#.#...#O#
#.###.#####.#O#
#.#.#.......#O#
#.#.#####.###O#
#..OOOOOOOOO#O#
###O#O#####O#O#
#OOO#O....#O#O#
#O#O#O###.#O#O#
#OOOOO#...#O#O#
#O###.#.#.#O#O#
#O..#.....#OOO#
###############

In the second example, there are 64 tiles that are part of at least one of the 
best paths:

#################
#...#...#...#..O#
#.#.#.#.#.#.#.#O#
#.#.#.#...#...#O#
#.#.#.#.###.#.#O#
#OOO#.#.#.....#O#
#O#O#.#.#.#####O#
#O#O..#.#.#OOOOO#
#O#O#####.#O###O#
#O#O#..OOOOO#OOO#
#O#O###O#####O###
#O#O#OOO#..OOO#.#
#O#O#O#####O###.#
#O#O#OOOOOOO..#.#
#O#O#O#########.#
#O#OOO..........#
#################

Analyze your map further. How many tiles are part of at least one of the best 
paths through the maze?
"""

optimal_seats = []
for reindeer in p_reindeer
    if reindeer.tot_cost == min_cost
        append!(optimal_seats, reindeer.p_cord)
    end
    unique!(optimal_seats)
end

# Slightly misuse of the struct, I just want to print 
# all the optimal seats in the map using the function 
# made for Reindeers 
optimal_seats_reindeer = Reindeer(optimal_seats, 0, 0)
# print_map(map, optimal_seats_reindeer)

n_optimal_seats = length(optimal_seats)
println("Number of optimal seats: $n_optimal_seats")