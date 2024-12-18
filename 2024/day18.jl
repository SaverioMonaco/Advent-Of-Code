"""
--- Day 18: RAM Run ---

You and The Historians look a lot more pixelated than you remember. You're 
inside a computer at the North Pole!

Just as you're about to check out your surroundings, a program runs up to you. 
"This region of memory isn't safe! The User misunderstood what a pushdown 
automaton is and their algorithm is pushing whole bytes down on top of us! Run!"

The algorithm is fast - it's going to cause a byte to fall into your memory 
space once every nanosecond! Fortunately, you're faster, and by quickly 
scanning the algorithm, you create a list of which bytes will fall (your 
puzzle input) in the order they'll land in your memory space.

Your memory space is a two-dimensional grid with coordinates that range from 0 
to 70 both horizontally and vertically. However, for the sake of example, 
suppose you're on a smaller grid with coordinates that range from 0 to 6 and 
the following list of incoming byte positions:

5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0

Each byte position is given as an X,Y coordinate, where X is the distance from 
the left edge of your memory space and Y is the distance from the top edge of 
your memory space.

You and The Historians are currently in the top left corner of the memory 
space (at 0,0) and need to reach the exit in the bottom right corner (at 70,70 
in your memory space, but at 6,6 in this example). You'll need to simulate the 
falling bytes to plan out where it will be safe to run; for now, simulate just 
the first few bytes falling into your memory space.

As bytes fall into your memory space, they make that coordinate corrupted. 
Corrupted memory coordinates cannot be entered by you or The Historians, so you
'll need to plan your route carefully. You also cannot leave the boundaries of 
the memory space; your only hope is to reach the exit.

In the above example, if you were to draw the memory space after the first 12 
bytes have fallen (using . for safe and # for corrupted), it would look like this:

...#...
..#..#.
....#..
...#..#
..#..#.
.#..#..
#.#....

You can take steps up, down, left, or right. After just 12 bytes have 
corrupted locations in your memory space, the shortest path from the top left 
corner to the exit would take 22 steps. Here (marked with O) is one such path:

OO.#OOO
.O#OO#O
.OOO#OO
...#OO#
..#OO#.
.#.O#..
#.#OOOO

Simulate the first kilobyte (1024 bytes) falling onto your memory space. 
Afterward, what is the minimum number of steps needed to reach the exit?
"""

function load_map(file_path, size, n_bytes)
    # Create the outline with boundaries
    boundary_row = repeat(["#"], size[1]+2)
    middle_row = vcat(["#"], repeat(["."], size[1]), ["#"])
    map = [boundary_row]
    for _ in range(1, size[2])
        push!(map, middle_row)
    end
    push!(map, boundary_row)

    # Make it a matrix
    map_matrix = hcat(map ...)
    # Highlight the starting and end points with S and E
    map_matrix[2,2] = "S"
    map_matrix[end-1, end-1] = "E"
    
    # Load the corrupted location
    p_corrupt_cord = [parse.(Int, inner) for inner in split.(readlines(file_path), ",")]

    # Corrupt the locations
    for corrupt_cord in p_corrupt_cord[1:n_bytes]
        map_matrix[corrupt_cord[1]+2, corrupt_cord[2]+2] = "#"
    end

    return map_matrix
end

function print_map(map)
    # Print each row, substituting 0 with "."
    for row in eachcol(map)
        println(join([x == "." ? " " : x for x in row]))
    end
end

function step(path, direction)
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
    
    new_cord = path[end] .+ increment

    new_path = vcat(path, [new_cord])
    return new_path, length(new_path)
end

# A factor that detemines how much the path is just 
# goofing around, you increase your score if you go 
# <- or ^ 
# while nothing happends if you go 
# -> or v
# 
# Which is applicable in this case where the start
# is on the top left and the goal on the bottom right
function goofing_factor(path)
    p_difference = diff(path, dims=1)
    g_factor = count(x -> x == -1, vcat(p_difference...))
    return g_factor
end

function shortest_path(map, goofing_cutoff)
    S_cord = collect(Tuple(findfirst(x-> x == "S", map)))
    E_cord = collect(Tuple(findfirst(x-> x == "E", map)))
    
    p_path = [[S_cord]]    

    map_cost = fill(149492, size(map)...)
    p_path_successfull = []    
    while(length(p_path)) > 0
        p_new_path = []
        for path in p_path
            for direction in (0:3)
                (new_path, n_step) = step(path, direction)
                g_factor = goofing_factor(new_path)
                if g_factor < goofing_cutoff
                    # The idea is that if you already have a Reindeer that 
                    # got to this point at a lower cost, you might want to
                    # discard the current reindeer
                    # Reindeers?
                    if n_step < map_cost[new_path[end][1], new_path[end][2]]
                        map_cost[new_path[end][1], new_path[end][2]] = n_step
                        if new_path[end] == E_cord
                            push!(p_path_successfull, path)
                        elseif map[new_path[end][1], new_path[end][2]] == "." && !(new_path[end] in new_path[1:end-1])
                            push!(p_new_path, new_path)
                        end
                    end
                end
            end
        end
        p_path = p_new_path
    end
    return p_path_successfull
end

file_path = "./data/day18.txt"

map = load_map(file_path, (71,71), 1024)

print_map(map)

@time best_path = shortest_path(map, 60)

solution = length(best_path[1])

println("Minimum number of steps is $solution")

"""
--- Part Two ---

The Historians aren't as used to moving around in this pixelated universe as 
you are. You're afraid they're not going to be fast enough to make it to the 
exit before the path is completely blocked.

To determine how fast everyone needs to go, you need to determine the first 
byte that will cut off the path to the exit.

In the above example, after the byte at 1,1 falls, there is still a path to 
the exit:

O..#OOO
O##OO#O
O#OO#OO
OOO#OO#
###OO##
.##O###
#.#OOOO

However, after adding the very next byte (at 6,1), there is no longer a path 
to the exit:

...#...
.##..##
.#..#..
...#..#
###..##
.##.###
#.#....

So, in this example, the coordinates of the first byte that prevents the exit 
from being reachable are 6,1.

Simulate more of the bytes that are about to corrupt your memory space. What 
are the coordinates of the first byte that will prevent the exit from being 
reachable from your starting position? (Provide the answer as two integers 
separated by a comma with no other characters.)
"""

# I would rather go from the highest possible corruption to the lowest as solving the  
# more corrupted puzzles is easier

function find_blocking(file_path)
    p_corruption = readlines(file_path)
    max_corruption = length(p_corruption)

    for i in range(1, max_corruption)
        map = load_map(file_path, (71,71), max_corruption - i + 1)
        best_path = shortest_path(map, 1000)
        if length(best_path) > 0
            println("Possible path at $(max_corruption - i + 1)")
            println("Solution is $(p_corruption[max_corruption - i + 2])")
            break
        end
    end
end

@time find_blocking(file_path)