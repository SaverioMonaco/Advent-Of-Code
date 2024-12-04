"""
--- Day 4: Ceres Search ---

"Looks like the Chief's not here. Next!" One of The Historians pulls out a 
device and pushes the only button on it. After a brief flash, you recognize 
the interior of the Ceres monitoring station!

As the search for the Chief continues, a small Elf who lives on the station 
tugs on your shirt; she'd like to know if you could help her with her word 
search (your puzzle input). She only has to find one word: XMAS.

This word search allows words to be horizontal, vertical, diagonal, written 
backwards, or even overlapping other words. It's a little unusual, though, as 
you don't merely need to find one instance of XMAS - you need to find all of 
them. Here are a few ways XMAS might appear, where irrelevant characters have 
been replaced with .:

..X...
.SAMX.
.A..A.
XMAS.S
.X....

The actual word search will be full of letters instead. For example:

MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX

In this word search, XMAS occurs a total of 18 times; here's the same word 
search again, but where letters not involved in any XMAS have been replaced 
with .:

....XXMAS.
.SAMXMS...
...S..A...
..A.A.MS.X
XMASAMX.MM
X.....XA.A
S.S.S.S.SS
.A.A.A.A.A
..M.M.M.MM
.X.X.XMASX

Take a look at the little Elf's word search. How many times does XMAS appear?

"""

# Load the txt file 
p_data_row = readlines("./data/day4.txt")
pp_data    = [split(row, "") for row in p_data_row]

function check_pp_idx(pp_idx, x_max, y_max)
    for p_idx in pp_idx
        if (p_idx[1] < 1 || p_idx[1] > x_max || p_idx[2] < 1 || p_idx[2] > y_max)     
            return nothing
        end
    end

    return pp_idx
end

function get_word_pp_idx(p_idx :: Vector{Int}, direction :: Int)
    if direction == 0
        # --> + 0
        return [p_idx, p_idx + [+1, +0], p_idx + [+2, +0], p_idx + [+3, +0]]
    elseif direction == 1
        # \>  + +
        return [p_idx, p_idx + [+1, +1], p_idx + [+2, +2], p_idx + [+3, +3]]
    elseif  direction == 2
        # |v  0 +
        return [p_idx, p_idx + [+0, +1], p_idx + [+0, +2], p_idx + [+0, +3]]
    elseif direction == 3
        # </  - +
        return [p_idx, p_idx + [-1, +1], p_idx + [-2, +2], p_idx + [-3, +3]]
    elseif direction == 4
        # <-- - 0
        return [p_idx, p_idx + [-1, +0], p_idx + [-2, +0], p_idx + [-3, +0]]
    elseif direction == 5
        # <\  - - 
        return [p_idx, p_idx + [-1, -1], p_idx + [-2, -2], p_idx + [-3, -3]]
    elseif direction == 6
        # |^  0 - 
        return [p_idx, p_idx + [+0, -1], p_idx + [+0, -2], p_idx + [+0, -3]]
    elseif direction == 7
        # />  + - 
        return [p_idx, p_idx + [+1, -1], p_idx + [+2, -2], p_idx + [+3, -3]]
    else 
        return nothing
    end
end

n_candidate :: Int = 0

for y in range(1, size(pp_data, 1))
    for x in range(1, length(pp_data[y]))
        for direction in range(0,7)
            pp_idx = check_pp_idx(get_word_pp_idx([x, y], direction), size(pp_data, 1), length(pp_data[y]))
            if pp_idx != nothing
                candidate = [pp_data[p_idx[1]][p_idx[2]] for p_idx in pp_idx]
                if candidate == ["X", "M", "A", "S"]
                    n_candidate += 1
                end
            end
        end
    end
end

print("There are $(n_candidate) occurrences")

"""
--- Part Two ---

The Elf looks quizzically at you. Did you misunderstand the assignment?

Looking for the instructions, you flip over the word search to find that this 
isn't actually an XMAS puzzle; it's an X-MAS puzzle in which you're supposed 
to find two MAS in the shape of an X. One way to achieve that is like this:

M.S
.A.
M.S

Irrelevant characters have again been replaced with . in the above diagram. 
Within the X, each MAS can be written forwards or backwards.

Here's the same example from before, but this time all of the X-MASes have 
been kept instead:

.M.S......
..A..MSMS.
.M.S.MAA..
..A.ASMSM.
.M.S.M....
..........
S.S.S.S.S.
.A.A.A.A..
M.M.M.M.M.
..........

In this example, an X-MAS appears 9 times.

Flip the word search from the instructions back over to the word search side 
and try again. How many times does an X-MAS appear?
"""

function get_word_pp_idx2(p_idx :: Vector{Int})
    #  2 3
    #   1
    #  4 5
    return [p_idx + [-1, -1], p_idx + [+1, -1], p_idx + [-1, +1], p_idx + [+1, +1]]
end

n_candidate :: Int = 0

for y in range(1, size(pp_data, 1))
    for x in range(1, length(pp_data[y]))
        if pp_data[x][y] == "A"
            pp_idx = check_pp_idx(get_word_pp_idx2([x, y]), size(pp_data, 1), length(pp_data[y]))
            if pp_idx != nothing
                candidate = [pp_data[p_idx[1]][p_idx[2]] for p_idx in pp_idx]
                if candidate == ["M", "M", "S", "S"] || candidate == ["M", "S", "M", "S"] || candidate == ["S", "M", "S", "M"] || candidate == ["S", "S", "M", "M"]
                    n_candidate += 1
                end
            end
        end
    end
end

println("There are $(n_candidate) occurrences")