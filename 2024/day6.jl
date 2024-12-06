"""
--- Day 6: Guard Gallivant ---

The Historians use their fancy device again, this time to whisk you all away 
to the North Pole prototype suit manufacturing lab... in the year 1518! It 
turns out that having direct access to history is very convenient for a group 
of historians.

You still have to be careful of time paradoxes, and so it will be important to 
avoid anyone from 1518 while The Historians search for the Chief. Unfortunately
, a single guard is patrolling this part of the lab.

Maybe you can work out where the guard will go ahead of time so that The 
Historians can search safely?

You start by making a map (your puzzle input) of the situation. For example:

....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...

The map shows the current position of the guard with ^ (to indicate the guard 
is currently facing up from the perspective of the map). Any obstructions - 
crates, desks, alchemical reactors, etc. - are shown as #.

Lab guards in 1518 follow a very strict patrol protocol which involves 
repeatedly following these steps:

    If there is something directly in front of you, turn right 90 degrees.
    Otherwise, take a step forward.

Following the above protocol, the guard moves up several times until she 
reaches an obstacle (in this case, a pile of failed suit prototypes):

....#.....
....^....#
..........
..#.......
.......#..
..........
.#........
........#.
#.........
......#...

Because there is now an obstacle in front of the guard, she turns right before 
continuing straight in her new facing direction:

....#.....
........>#
..........
..#.......
.......#..
..........
.#........
........#.
#.........
......#...

Reaching another obstacle (a spool of several very long polymers), she turns 
right again and continues downward:

....#.....
.........#
..........
..#.......
.......#..
..........
.#......v.
........#.
#.........
......#...

This process continues for a while, but the guard eventually leaves the mapped 
area (after walking past a tank of universal solvent):

....#.....
.........#
..........
..#.......
.......#..
..........
.#........
........#.
#.........
......#v..

By predicting the guard's route, you can determine which specific positions in 
the lab will be in the patrol path. Including the guard's starting position, 
the positions visited by the guard before leaving the area are marked with an X:

....#.....
....XXXXX#
....X...X.
..#.X...X.
..XXXXX#X.
..X.X.X.X.
.#XXXXXXX.
.XXXXXXX#.
#XXXXXXX..
......#X..

In this example, the guard will visit 41 distinct positions on your map.

Predict the path of the guard. How many distinct positions will the guard 
visit before leaving the mapped area?
"""

function load_map(path :: String)
    return hcat(split.(readlines(path), "") ...)
end

function count_step(map)
    return count(x -> x == "X", map)
end

mutable struct Sbirro
    position  
    direction
    exit    
    has_stepped
end

function step!(Sbirro, map)
    Sbirro.has_stepped = false
    increase :: Tuple{Int, Int} = (0, 0)
    if     Sbirro.direction == 0 # ->
        increase = (+1, +0)
    elseif Sbirro.direction == 1 # |v
        increase = (+0, +1)
    elseif Sbirro.direction == 2 # <-
        increase = (-1, +0)
    elseif Sbirro.direction == 3 # |^
        increase = (+0, -1)
    else
        error("Invalid direction")
    end
    
    # println("Current position: $(Sbirro.position)")
    if false
        for y in range(Sbirro.position[2] - 2, Sbirro.position[2] + 2)
            row = []
            for x in range(Sbirro.position[1] - 5, Sbirro.position[1] + 5)
                if x < 1 || x > size(map, 1) || y < 1 || y > size(map, 2)
                    char = " "
                else
                    char = map[x, y]
                end
                push!(row, char)
            end
            println(join(row))
        end
    end
    new_position = Sbirro.position .+ increase

    if new_position[1] > size(map, 1) || 
       new_position[2] > size(map, 2) || 
       new_position[1] < 1 ||
       new_position[2] < 1
        Sbirro.exit = true
        map[Sbirro.position[1], Sbirro.position[2]] = "X"
        # print("exiting in $new_position")
    elseif map[new_position[1], new_position[2]] == "#"
        Sbirro.direction = (Sbirro.direction + 1) % 4
        # println("changed direction to: $(Sbirro.direction)")
    else
        # println("Moved from: $(Sbirro.position)")
        map[Sbirro.position[1], Sbirro.position[2]] = "X"
        Sbirro.position = Sbirro.position .+ increase
        map[Sbirro.position[1], Sbirro.position[2]] = "^"
        # println("        to: $(Sbirro.position)")
        Sbirro.has_stepped = true
    end
end   

function find_sbirro(map)
    return collect(Tuple(findfirst(x -> x == "^", map)))
end
    

map = load_map("./data/day6.txt")

agent = Sbirro(find_sbirro(map), 3, false, false)

while !agent.exit
    step!(agent, map)
end

println("Number of steps: $(count_step(map))")

"""
--- Part Two ---

While The Historians begin working around the guard's patrol route, you borrow 
their fancy device and step outside the lab. From the safety of a supply closet
, you time travel through the last few months and record the nightly status of 
the lab's guard post on the walls of the closet.

Returning after what seems like only a few seconds to The Historians, they 
explain that the guard's patrol area is simply too large for them to safely 
search the lab without getting caught.

Fortunately, they are pretty sure that adding a single new obstruction won't 
cause a time paradox. They'd like to place the new obstruction in such a way 
that the guard will get stuck in a loop, making the rest of the lab safe to search.

To have the lowest chance of creating a time paradox, The Historians would 
like to know all of the possible positions for such an obstruction. The new 
obstruction can't be placed at the guard's starting position - the guard is 
there right now and would notice.

In the above example, there are only 6 different positions where a new 
obstruction would cause the guard to get stuck in a loop. The diagrams of 
these six situations use O to mark the new obstruction, | to show a position 
where the guard moves up/down, - to show a position where the guard moves left/
right, and + to show a position where the guard moves both up/down and left/right.

Option one, put a printing press next to the guard's starting position:

....#.....
....+---+#
....|...|.
..#.|...|.
....|..#|.
....|...|.
.#.O^---+.
........#.
#.........
......#...

Option two, put a stack of failed suit prototypes in the bottom right quadrant of the mapped area:

....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
......O.#.
#.........
......#...

Option three, put a crate of chimney-squeeze prototype fabric next to the 
standing desk in the bottom right quadrant:

....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
.+----+O#.
#+----+...
......#...

Option four, put an alchemical retroencabulator near the bottom left corner:

....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
..|...|.#.
#O+---+...
......#...

Option five, put the alchemical retroencabulator a bit to the right instead:

....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
....|.|.#.
#..O+-+...
......#...

Option six, put a tank of sovereign glue right next to the tank of universal solvent:

....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
.+----++#.
#+----++..
......#O..

It doesn't really matter what you choose to use as an obstacle so long as you 
and The Historians can put it into position without the guard noticing. The 
important thing is having enough options that you can find one that minimizes 
time paradoxes, and in this example, there are 6 different positions you could choose.

You need to get the guard stuck in a loop by adding a single new obstruction. 
How many different positions could you choose for this obstruction?
"""
function print_map(map)
    for row_idx in range(1, size(map, 2))
        println(join(map[:, row_idx]))
    end
end

n_obst = 0

map = load_map("./data/day6.txt")

p_agent_position = []
agent = Sbirro(find_sbirro(map), 3, false, false)
while !agent.exit
    push!(p_agent_position, agent.position)
    step!(agent, map)
end

p_obstacle_tested = []
map = load_map("./data/day6.txt")
agent = Sbirro(find_sbirro(map), 3, false, false)

for t in range(1, length(p_agent_position)-1)
    # print_map(map)
    println("$t/$(length(p_agent_position)) | $n_obst")
    # println(agent.position, " ", p_agent_position[t])
    next_step = p_agent_position[t+1]
    if next_step != agent.position && map[next_step[1], next_step[2]] == "."
        # Create paradox
        map_whatif = copy(map)    
        agent_whatif = Sbirro(agent.position, agent.direction, false, false)
        map_whatif[next_step[1], next_step[2]] = "#"
        
        in_loop = false
        history = []
        while !in_loop && !agent_whatif.exit
            # print_map(map_whatif)
            # sleep(0.1)
            step!(agent_whatif, map_whatif)
            if agent_whatif.has_stepped
                if [agent_whatif.direction, agent_whatif.position[1], agent_whatif.position[2]] in history
                    in_loop = true
                    n_obst += 1
                    println("# at $next_step crates a loop")
                else
                    push!(history, [agent_whatif.direction, agent_whatif.position[1], agent_whatif.position[2]])
                end
            end
        end
        
    end
    step!(agent, map)
    t += 1
    # sleep(1)
end



for x in range(1, size(map, 1))
    for y in range(1, size(map, 2))
        println("iteration $it: $n_obst")
        it += 1
        map = load_map("./data/day6.txt")
        if map[x, y] == "."
            map[x, y] = "#"
            history = []
            agent = Sbirro(find_sbirro(map), 3, false, false)
            while !agent.exit
                step!(agent, map)
                if [agent.direction, agent.position[1], agent.position[2]] in history
                    agent.exit = true
                    n_obst += 1
                else
                    push!(history, [agent.direction, agent.position[1], agent.position[2]])
                end
            end
        end
    end
end

println(n_obst)