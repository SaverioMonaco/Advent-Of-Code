"""
--- Day 8: Resonant Collinearity ---

You find yourselves on the roof of a top-secret Easter Bunny installation.

While The Historians do their thing, you take a look at the familiar huge 
antenna. Much to your surprise, it seems to have been reconfigured to emit a 
signal that makes people 0.1% more likely to buy Easter Bunny brand Imitation 
Mediocre Chocolate as a Christmas gift! Unthinkable!

Scanning across the city, you find that there are actually many such antennas. 
Each antenna is tuned to a specific frequency indicated by a single lowercase 
letter, uppercase letter, or digit. You create a map (your puzzle input) of 
these antennas. For example:

............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............

The signal only applies its nefarious effect at specific antinodes based on 
the resonant frequencies of the antennas. In particular, an antinode occurs at 
any point that is perfectly in line with two antennas of the same frequency - 
but only when one of the antennas is twice as far away as the other. This 
means that for any pair of antennas with the same frequency, there are two 
antinodes, one on either side of them.

So, for these two antennas with frequency a, they create the two antinodes 
marked with #:

..........
...#......
..........
....a.....
..........
.....a....
..........
......#...
..........
..........

Adding a third antenna with the same frequency creates several more antinodes. 
It would ideally add four antinodes, but two are off the right side of the map
, so instead it adds only two:

..........
...#......
#.........
....a.....
........a.
.....a....
..#.......
......#...
..........
..........

Antennas with different frequencies don't create antinodes; A and a count as 
different frequencies. However, antinodes can occur at locations that contain 
antennas. In this diagram, the lone antenna with frequency capital A creates 
no antinodes but has a lowercase-a-frequency antinode at its location:

..........
...#......
#.........
....a.....
........a.
.....a....
..#.......
......A...
..........
..........

The first example has antennas with two different frequencies, so the 
antinodes they create look like this, plus an antinode overlapping the topmost 
A-frequency antenna:

......#....#
...#....0...
....#0....#.
..#....0....
....0....#..
.#....A.....
...#........
#......#....
........A...
.........A..
..........#.
..........#.

Because the topmost A-frequency antenna overlaps with a 0-frequency antinode, 
there are 14 total unique locations that contain an antinode within the bounds 
of the map.

Calculate the impact of the signal. How many unique locations within the 
bounds of the map contain an antinode?
"""

using Combinatorics:  combinations

path = "./data/day8.txt"

function load(path :: String)
    data = hcat(split.(readlines(path), "") ...)
    return data
end

function print_map(map)
    for row in eachcol(map)
        println(join(row))
    end
end

map = load(path)

println("Map loaded:")
print_map(map)

function get_dict_antenna(map)
    p_antenna = Dict()
    for char in unique(map)
        if !(char in [".", "#"])
            char_coordinates = [collect(Tuple(cord)) for cord in findall(x -> x == char, map)]
            p_antenna[char]= char_coordinates
        end
    end
    return p_antenna
end

dic_antenna = get_dict_antenna(map)
println("Antennas:")
for (key, value) in dic_antenna
    println(" $key: $value")
end

function find_pair_antinode(cord1, cord2, map)
    diff = cord2 - cord1
    p_antinode = [cord1 - diff, cord2 + diff]
    p_antinode_filtered = []
    for antinode in p_antinode
        if !(antinode[1] <= 0 || antinode[1] > size(map, 1) || antinode[2] <= 0 || antinode[2] > size(map, 2))
            push!(p_antinode_filtered, antinode)
        end
    end
    return p_antinode_filtered
end

function find_all_antinode(p_antenna_cord, map)
    comb = combinations(p_antenna_cord, 2)
    p_antinode = []
    for (cord1, cord2) in comb
        pair_antinode = find_pair_antinode(cord1, cord2, map)
        if length(pair_antinode) > 0
            for antinode in pair_antinode
                push!(p_antinode, antinode)
            end
        end
    end
    return p_antinode
end

function update_map!(map)
    solution_mat = zeros(size(map,1), size(map,2))
    dict_antenna = get_dict_antenna(map)
    for (antenna, p_cord) in dict_antenna
        println("   $antenna:$p_cord")
        p_antinode = find_all_antinode(p_cord, map)

        for antinode in p_antinode
            solution_mat[antinode[1], antinode[2]] = 1
            if map[antinode[1], antinode[2]] == "." 
                map[antinode[1], antinode[2]] = "#"
            end
        end
        println("      Antinodes: $p_antinode")
        print_map(map)
    end
    return sum(solution_mat)
end

map = load(path)
solution = update_map!(map)

"""
--- Part Two ---

Watching over your shoulder as you work, one of The Historians asks if you 
took the effects of resonant harmonics into your calculations.

Whoops!

After updating your model, it turns out that an antinode occurs at any grid 
position exactly in line with at least two antennas of the same frequency, 
regardless of distance. This means that some of the new antinodes will occur 
at the position of each antenna (unless that antenna is the only one of its 
frequency).

So, these three T-frequency antennas now create many antinodes:

T....#....
...T......
.T....#...
.........#
..#.......
..........
...#......
..........
....#.....
..........

In fact, the three T-frequency antennas are all exactly in line with two 
antennas, so they are all also antinodes! This brings the total number of 
antinodes in the above example to 9.

The original example now has 34 antinodes, including the antinodes that appear 
on every antenna:

##....#....#
.#.#....0...
..#.#0....#.
..##...0....
....0....#..
.#...#A....#
...#..#.....
#....#.#....
..#.....A...
....#....A..
.#........#.
...#......##

Calculate the impact of the signal using this updated model. How many unique 
locations within the bounds of the map contain an antinode?
"""

function find_pair_antinode(cord1, cord2, map)
    diff = cord2 - cord1
    p_antinode_filtered = []
    for k in range(0, sizeof(map))
        antinode = cord1 - k*diff
        if !(antinode[1] <= 0 || antinode[1] > size(map, 1) || antinode[2] <= 0 || antinode[2] > size(map, 2))
            push!(p_antinode_filtered, antinode)
        else
            break
        end
    end

    for k in range(0, sizeof(map))
        antinode = cord2 + k*diff
        if !(antinode[1] <= 0 || antinode[1] > size(map, 1) || antinode[2] <= 0 || antinode[2] > size(map, 2))
            push!(p_antinode_filtered, antinode)
        else
            break
        end
    end

    return p_antinode_filtered
end

function find_all_antinode(p_antenna_cord, map)
    comb = combinations(p_antenna_cord, 2)
    p_antinode = []
    for (cord1, cord2) in comb
        pair_antinode = find_pair_antinode(cord1, cord2, map)
        if length(pair_antinode) > 0
            for antinode in pair_antinode
                push!(p_antinode, antinode)
            end
        end
    end
    return p_antinode
end

function update_map!(map)
    solution_mat = zeros(size(map,1), size(map,2))
    dict_antenna = get_dict_antenna(map)    
    for (antenna, p_cord) in dict_antenna
        println("   $antenna:$p_cord")
        p_antinode = find_all_antinode(p_cord, map)

        for antinode in p_antinode
            solution_mat[antinode[1], antinode[2]] = 1
            if map[antinode[1], antinode[2]] == "." 
                map[antinode[1], antinode[2]] = "#"
            end
        end
        println("      Antinodes: $p_antinode")
        print_map(map)
    end
    return sum(solution_mat)
end

map = load(path)
solution = update_map!(map)