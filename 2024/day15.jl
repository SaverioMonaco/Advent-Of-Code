"""
--- Day 15: Warehouse Woes ---

You appear back inside your own mini submarine! Each Historian drives their 
mini submarine in a different direction; maybe the Chief has his own submarine 
down here somewhere as well?

You look up to see a vast school of lanternfish swimming past you. On closer 
inspection, they seem quite anxious, so you drive your mini submarine over to 
see if you can help.

Because lanternfish populations grow rapidly, they need a lot of food, and 
that food needs to be stored somewhere. That's why these lanternfish have 
built elaborate warehouse complexes operated by robots!

These lanternfish seem so anxious because they have lost control of the robot 
that operates one of their most important warehouses! It is currently running 
amok, pushing around boxes in the warehouse with no regard for lanternfish 
logistics or lanternfish inventory management strategies.

Right now, none of the lanternfish are brave enough to swim up to an 
unpredictable robot so they could shut it off. However, if you could 
anticipate the robot's movements, maybe they could find a safe option.

The lanternfish already have a map of the warehouse and a list of movements 
the robot will attempt to make (your puzzle input). The problem is that the 
movements will sometimes fail as boxes are shifted around, making the actual 
movements of the robot difficult to predict.

For example:

##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^

As the robot (@) attempts to move, if there are any boxes (O) in the way, the 
robot will also attempt to push those boxes. However, if this action would 
cause the robot or a box to move into a wall (#), nothing moves instead, 
including the robot. The initial positions of these are shown on the map at 
the top of the document the lanternfish gave you.

The rest of the document describes the moves (^ for up, v for down, < for left
, > for right) that the robot will attempt to make, in order. (The moves form 
a single giant sequence; they are broken into multiple lines just to make copy-
pasting easier. Newlines within the move sequence should be ignored.)

Here is a smaller example to get started:

########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<

Were the robot to attempt the given sequence of moves, it would push around 
the boxes as follows:

Initial state:
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move <:
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move ^:
########
#.@O.O.#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move ^:
########
#.@O.O.#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move >:
########
#..@OO.#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move >:
########
#...@OO#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move >:
########
#...@OO#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move v:
########
#....OO#
##..@..#
#...O..#
#.#.O..#
#...O..#
#...O..#
########

Move v:
########
#....OO#
##..@..#
#...O..#
#.#.O..#
#...O..#
#...O..#
########

Move <:
########
#....OO#
##.@...#
#...O..#
#.#.O..#
#...O..#
#...O..#
########

Move v:
########
#....OO#
##.....#
#..@O..#
#.#.O..#
#...O..#
#...O..#
########

Move >:
########
#....OO#
##.....#
#...@O.#
#.#.O..#
#...O..#
#...O..#
########

Move >:
########
#....OO#
##.....#
#....@O#
#.#.O..#
#...O..#
#...O..#
########

Move v:
########
#....OO#
##.....#
#.....O#
#.#.O@.#
#...O..#
#...O..#
########

Move <:
########
#....OO#
##.....#
#.....O#
#.#O@..#
#...O..#
#...O..#
########

Move <:
########
#....OO#
##.....#
#.....O#
#.#O@..#
#...O..#
#...O..#
########

The larger example has many more moves; after the robot has finished those 
moves, the warehouse would look like this:

##########
#.O.O.OOO#
#........#
#OO......#
#OO@.....#
#O#.....O#
#O.....OO#
#O.....OO#
#OO....OO#
##########

The lanternfish use their own custom Goods Positioning System (GPS for short) 
to track the locations of the boxes. The GPS coordinate of a box is equal to 
100 times its distance from the top edge of the map plus its distance from the 
left edge of the map. (This process does not stop at wall tiles; measure all 
the way to the edges of the map.)

So, the box shown below has a distance of 1 from the top edge of the map and 4 
from the left edge of the map, resulting in a GPS coordinate of 100 * 1 + 4 = 104.

#######
#...O..
#......

The lanternfish would like to know the sum of all boxes' GPS coordinates after 
the robot finishes moving. In the larger example, the sum of all boxes' GPS 
coordinates is 10092. In the smaller example, the sum is 2028.

Predict the motion of the robot and boxes in the warehouse. After the robot is 
finished moving, what is the sum of all boxes' GPS coordinates?
"""

function load(file_path)
    # data = hcat(split.(readlines(file_path), "") ...)
    data = readlines(file_path)
    split_idx = findfirst(x-> x == "", data)
    warehouse = hcat(split.(data[1:split_idx-1], "") ...)
    p_movement = split(join(data[split_idx+1:end]), "")

    return warehouse, p_movement
end

function print_map(map)
    # Print each row, substituting 0 with "."
    for row in eachcol(map)
        println(join([x == "." ? " " : x for x in row]))
    end
end

function locate(map)
    return collect(Tuple(findfirst(x -> x == "@", map)))
end

function step!(map, direction)
    robot_idx = locate(map)
    increment     = [ 0, 0]
    if direction == "<"
        increment = [-1, 0]
    elseif direction == "^"
        increment = [0, -1]
    elseif direction == ">"
        increment = [+1, 0]
    elseif direction == "v"
        increment = [0, +1]
    else
        error("Invalid direction: $direction")
    end

    new_idx = robot_idx .+ increment
    if map[new_idx[1], new_idx[2]] == "."
        map[robot_idx[1], robot_idx[2]] = "."
        map[new_idx[1], new_idx[2]] = "@"
    elseif map[new_idx[1], new_idx[2]] == "#"
        # actually nothing
    elseif map[new_idx[1], new_idx[2]] == "O"
        k = 2
        new_new_idx = robot_idx .+ (k .* increment)
        while map[new_new_idx[1], new_new_idx[2]] == "O"
            k += 1
            new_new_idx = robot_idx .+ (k .* increment)
        end
        if map[new_new_idx[1], new_new_idx[2]] == "."
            map[new_new_idx[1], new_new_idx[2]] = "O"
            map[robot_idx[1], robot_idx[2]] = "."
            map[new_idx[1], new_idx[2]] = "@"
        end
    else
        error("What is $(map[new_idx[1], new_idx[2]])")
    end

end

function get_GPS(map)
    GPS = 0
    for x in range(1, size(map, 1))
        for y in range(1, size(map, 2))
            if map[x, y] == "O"
                GPS += (x-1) + 100*(y-1)
            end
        end
    end
    return GPS
end

warehouse, p_movement = load("./data/day15.txt")

# println("START")
# print_map(warehouse)
# println()
for i in range(1,length(p_movement))
    # println("Step $i: $(p_movement[i])")
    step!(warehouse, p_movement[i])
    # print_map(warehouse)
    # println()
end

print("GPS = $(get_GPS(warehouse))")

"""
--- Part Two ---

The lanternfish use your information to find a safe moment to swim in and turn 
off the malfunctioning robot! Just as they start preparing a festival in your 
honor, reports start coming in that a second warehouse's robot is also 
malfunctioning.

This warehouse's layout is surprisingly similar to the one you just helped. 
There is one key difference: everything except the robot is twice as wide! The 
robot's list of movements doesn't change.

To get the wider warehouse's map, start with your original map and, for each 
tile, make the following changes:

    If the tile is #, the new map contains ## instead.
    If the tile is O, the new map contains [] instead.
    If the tile is ., the new map contains .. instead.
    If the tile is @, the new map contains @. instead.

This will produce a new warehouse map which is twice as wide and with wide 
boxes that are represented by []. (The robot does not change size.)

The larger example from before would now look like this:

####################
##....[]....[]..[]##
##............[]..##
##..[][]....[]..[]##
##....[]@.....[]..##
##[]##....[]......##
##[]....[]....[]..##
##..[][]..[]..[][]##
##........[]......##
####################

Because boxes are now twice as wide but the robot is still the same size and 
speed, boxes can be aligned such that they directly push two other boxes at 
once. For example, consider this situation:

#######
#...#.#
#.....#
#..OO@#
#..O..#
#.....#
#######

<vv<<^^<<^^

After appropriately resizing this map, the robot would push around these boxes 
as follows:

Initial state:
##############
##......##..##
##..........##
##....[][]@.##
##....[]....##
##..........##
##############

Move <:
##############
##......##..##
##..........##
##...[][]@..##
##....[]....##
##..........##
##############

Move v:
##############
##......##..##
##..........##
##...[][]...##
##....[].@..##
##..........##
##############

Move v:
##############
##......##..##
##..........##
##...[][]...##
##....[]....##
##.......@..##
##############

Move <:
##############
##......##..##
##..........##
##...[][]...##
##....[]....##
##......@...##
##############

Move <:
##############
##......##..##
##..........##
##...[][]...##
##....[]....##
##.....@....##
##############

Move ^:
##############
##......##..##
##...[][]...##
##....[]....##
##.....@....##
##..........##
##############

Move ^:
##############
##......##..##
##...[][]...##
##....[]....##
##.....@....##
##..........##
##############

Move <:
##############
##......##..##
##...[][]...##
##....[]....##
##....@.....##
##..........##
##############

Move <:
##############
##......##..##
##...[][]...##
##....[]....##
##...@......##
##..........##
##############

Move ^:
##############
##......##..##
##...[][]...##
##...@[]....##
##..........##
##..........##
##############

Move ^:
##############
##...[].##..##
##...@.[]...##
##....[]....##
##..........##
##..........##
##############

This warehouse also uses GPS to locate the boxes. For these larger boxes, 
distances are measured from the edge of the map to the closest edge of the box 
in question. So, the box shown below has a distance of 1 from the top edge of 
the map and 5 from the left edge of the map, resulting in a GPS coordinate of 
100 * 1 + 5 = 105.

##########
##...[]...
##........

In the scaled-up version of the larger example from above, after the robot has 
finished all of its moves, the warehouse would look like this:

####################
##[].......[].[][]##
##[]...........[].##
##[]........[][][]##
##[]......[]....[]##
##..##......[]....##
##..[]............##
##..@......[].[][]##
##......[][]..[]..##
####################

The sum of these boxes' GPS coordinates is 9021.

Predict the motion of the robot and boxes in this new, scaled-up warehouse. 
What is the sum of all boxes' final GPS coordinates?
"""

function increase(map)
    new_map = []
    for row in eachcol(map)
        new_row = []
        for thing in row
            if thing == "O"
                append!(new_row, ["[", "]"])
            elseif thing == "@"
                append!(new_row, ["@", "."])
            else
                append!(new_row, [thing, thing])
            end
        end
        push!(new_map, new_row)
    end
    return hcat(new_map ...)
end

function step!(map, direction)
    robot_idx = locate(map)
    increment     = [ 0, 0]
    if direction == "<"
        increment = [-1, 0]
    elseif direction == "^"
        increment = [0, -1]
    elseif direction == ">"
        increment = [+1, 0]
    elseif direction == "v"
        increment = [0, +1]
    else
        error("Invalid direction: $direction")
    end

    new_idx = robot_idx .+ increment
    if map[new_idx[1], new_idx[2]] == "."
        map[robot_idx[1], robot_idx[2]] = "."
        map[new_idx[1], new_idx[2]] = "@"
    elseif map[new_idx[1], new_idx[2]] == "#"
        # actually nothing
    elseif map[new_idx[1], new_idx[2]] == "[" || map[new_idx[1], new_idx[2]] == "]"
        if direction     == "<"
            k = 2
            new_new_idx = robot_idx .+ (k .* increment)
            while map[new_new_idx[1], new_new_idx[2]] == "[" || map[new_new_idx[1], new_new_idx[2]] == "]"
                k += 1
                new_new_idx = robot_idx .+ (k .* increment)
            end
            if map[new_new_idx[1], new_new_idx[2]] == "."
                map[robot_idx[1], robot_idx[2]] = "."
                map[new_idx[1], new_idx[2]] = "@"
                p_graph = ["]", "["]
                for j in range(2,k)
                    j_idx = robot_idx .+ (j .* increment)
                    map[j_idx[1], j_idx[2]] = p_graph[j%2+1] 
                end
            end
        elseif direction == ">"
            k = 2
            new_new_idx = robot_idx .+ (k .* increment)
            while map[new_new_idx[1], new_new_idx[2]] == "[" || map[new_new_idx[1], new_new_idx[2]] == "]"
                k += 1
                new_new_idx = robot_idx .+ (k .* increment)
            end
            if map[new_new_idx[1], new_new_idx[2]] == "."
                map[robot_idx[1], robot_idx[2]] = "."
                map[new_idx[1], new_idx[2]] = "@"
                p_graph = ["[", "]"]
                for j in range(2,k)
                    j_idx = robot_idx .+ (j .* increment)
                    map[j_idx[1], j_idx[2]] = p_graph[j%2+1] 
                end
            end
        elseif direction == "^" || direction == "v"
            function box_tree(map, position, direction)
                function add_box(map, position, increment)
                    if map[position[1], position[2]+increment] == "[" 
                        return [position[1], position[2]+increment]
                    elseif map[position[1], position[2]+increment] == "]" 
                        return [position[1]-1, position[2]+increment]
                    end
                end

                if direction == "^"
                    increment = -1
                elseif direction == "v"
                    increment = +1
                else
                    error("Invalid direction $direction")
                end

                p_box = [add_box(map, position, increment)]
                p_box_prev = [add_box(map, position, increment)]
                                
                while length(p_box_prev) > 0
                    p_box_aft = []
                    for box in p_box_prev
                        push!(p_box_aft, add_box(map, box, increment)) 
                    end
                    p_box_aft = unique(p_box_aft)
                    p_box_aft = filter(x -> !isnothing(x), p_box_aft)
                    println(p_box_aft)
                    if length(p_box_aft) > 0
                        append!(p_box, p_box_aft)
                        p_box_prev = p_box_aft
                    else
                        p_box_prev = []
                    end
                end
                return p_box
            end

            function superpush!(map, p_box, direction, robot_idx)
                if direction == "^"
                    increment = -1
                elseif direction == "v"
                    increment = +1
                else
                    error("Invalid direction $direction")
                end

                can_be_pushed = true
                for box in p_box
                    if map[box[1], box[2]+increment] == "#" || map[box[1]+1, box[2]+increment] == "#"
                        can_be_pushed = false
                    end
                end

                if can_be_pushed
                    for box in p_box
                        map[box[1], box[2]] = "."
                        map[box[1]+1, box[2]] = "."
                    end
                    for box in p_box
                        map[box[1], box[2]+increment] = "["
                        map[box[1]+1, box[2]+increment] = "]"
                    end
                    map[robot_idx[1], robot_idx[2]] = "."
                    map[robot_idx[1], robot_idx[2]+increment] = "@"
                end
            end
            p_box = box_tree(map, robot_idx, direction)
            superpush!(map, p_box, direction, robot_idx)
        end
    end
end

warehouse, p_movement = load("./data/day15.txt")
println("Before:")
print_map(warehouse)
println("After:")
big_warehouse = increase(warehouse)
print_map(big_warehouse)

for movement in p_movement
    println(movement)
    step!(big_warehouse, movement)
    print_map(big_warehouse)
    sleep(.1)
end
print_map(big_warehouse)