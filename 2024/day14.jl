"""
--- Day 14: Restroom Redoubt ---

One of The Historians needs to use the 
bathroom; fortunately, you know there's a bathroom near an unvisited location 
on their list, and so you're all quickly teleported directly to the lobby of 
Easter Bunny Headquarters.

Unfortunately, EBHQ seems to have "improved" bathroom security again after 
your last visit. The area outside the bathroom is swarming with robots!

To get The Historian safely to the bathroom, you'll need a way to predict 
where the robots will be in the future. Fortunately, they all seem to be 
moving on the tile floor in predictable straight lines.

You make a list (your puzzle input) of all of the robots' current positions (p
) and velocities (v), one robot per line. For example:

p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3

Each robot's position is given as p=x,y where x represents the number of tiles 
the robot is from the left wall and y represents the number of tiles from the 
top wall (when viewed from above). So, a position of p=0,0 means the robot is 
all the way in the top-left corner.

Each robot's velocity is given as v=x,y where x and y are given in tiles per 
second. Positive x means the robot is moving to the right, and positive y 
means the robot is moving down. So, a velocity of v=1,-2 means that each second
, the robot moves 1 tile to the right and 2 tiles up.

The robots outside the actual bathroom are in a space which is 101 tiles wide 
and 103 tiles tall (when viewed from above). However, in this example, the 
robots are in a space which is only 11 tiles wide and 7 tiles tall.

The robots are good at navigating over/under each other (due to a combination 
of springs, extendable legs, and quadcopters), so they can share the same tile 
and don't interact with each other. Visually, the number of robots on each 
tile in this example looks like this:

1.12.......
...........
...........
......11.11
1.1........
.........1.
.......1...

These robots have a unique feature for maximum bathroom security: they can 
teleport. When a robot would run into an edge of the space they're in, they 
instead teleport to the other side, effectively wrapping around the edges. 
Here is what robot p=2,4 v=2,-3 does for the first few seconds:

Initial state:
...........
...........
...........
...........
..1........
...........
...........

After 1 second:
...........
....1......
...........
...........
...........
...........
...........

After 2 seconds:
...........
...........
...........
...........
...........
......1....
...........

After 3 seconds:
...........
...........
........1..
...........
...........
...........
...........

After 4 seconds:
...........
...........
...........
...........
...........
...........
..........1

After 5 seconds:
...........
...........
...........
.1.........
...........
...........
...........

The Historian can't wait much longer, so you don't have to simulate the robots 
for very long. Where will the robots be after 100 seconds?

In the above example, the number of robots on each tile after 100 seconds has 
elapsed looks like this:

......2..1.
...........
1..........
.11........
.....1.....
...12......
.1....1....

To determine the safest area, count the number of robots in each quadrant 
after 100 seconds. Robots that are exactly in the middle (horizontally or 
vertically) don't count as being in any quadrant, so the only relevant robots are:

..... 2..1.
..... .....
1.... .....
           
..... .....
...12 .....
.1... 1....

In this example, the quadrants contain 1, 3, 4, and 1 robot. Multiplying these 
together gives a total safety factor of 12.

Predict the motion of the robots in your list within a space which is 101 
tiles wide and 103 tiles tall. What will the safety factor be after exactly 
100 seconds have elapsed?
"""

mutable struct Robot
    p_cord::Tuple{Int, Int}
    p_vel ::Tuple{Int, Int}
end

function load(path :: String)
    function load_Robot(row) 
        pos_regex = r"p=(-?\d+),(-?\d+)"
        vel_regex = r"v=(-?\d+),(-?\d+)"

        pos = (parse(Int, match(pos_regex, row)[1]), parse(Int, match(pos_regex, row)[2]))
        vel = (parse(Int, match(vel_regex, row)[1]), parse(Int, match(vel_regex, row)[2]))
        
        return Robot(pos, vel)
    end

    p_Robot = load_Robot.(readlines(path))
    return p_Robot
end

function wrap_coordinate(coord, space)
    return mod(coord, space)
end

function step!(robot, p_space)
    robot.p_cord = wrap_coordinate.(robot.p_cord .+ robot.p_vel, p_space)
end

function which_quadrant(robot, p_space)
    if robot.p_cord[1] == div(p_space[1], 2) || robot.p_cord[2] == div(p_space[2], 2) 
        return nothing
    else
        quadrant_bin = div.(robot.p_cord, div.(p_space, 2) .+ 1)
        return parse(Int, join(quadrant_bin), base=2)
    end
end

function printmap(p_robot, p_space)
    matrix = zeros(Int, p_space...)
    
    for robot in p_robot
        matrix[robot.p_cord[1]+1, robot.p_cord[2]+1] += 1
    end
    
    # Print each row, substituting 0 with "."
    for row in eachcol(matrix)
        println(join([x == 0 ? ". " : string(x)*" " for x in row]))
    end
end

file_path = "./data/day14.txt"
data = load(file_path)

p_space = (101, 103)

printmap(data, p_space)
for i in (1:100)
    step!.(data, Ref(p_space))
    println("Step $i")
    printmap(data, p_space)
end

p_quadrant = filter(!isnothing, which_quadrant.(data, Ref(p_space)))

solution = 1
for i in (0:3)
    n_robot = (length(filter(x -> x==i, p_quadrant)))
    solution *= n_robot
    println("Quadrant $i: $n_robot")
end

println("Solution : $solution")

"""
--- Part Two ---

During the bathroom break, someone notices that these robots seem awfully 
similar to ones built and used at the North Pole. If they're the same type of 
robots, they should have a hard-coded Easter egg: very rarely, most of the 
robots should arrange themselves into a picture of a Christmas tree.

What is the fewest number of seconds that must elapse for the robots to 
display the Easter egg?
"""

function closeness(p_robot)
    function dist(robot1, robot2)
        return sum(abs.(robot1.p_cord .- robot2.p_cord))
    end

    closeness_value = 0
    for robot1 in p_robot
        for robot2 in p_robot
            if dist(robot1, robot2) < 2 && dist(robot1, robot2) > 0
                closeness_value += 1
            end
        end
    end
    return closeness_value
end

function printmap_small(p_robot, p_space)
    matrix = zeros(Int, p_space...)
    
    for robot in p_robot
        matrix[robot.p_cord[1]+1, robot.p_cord[2]+1] += 1
    end
    
    # Print each row, substituting 0 with "."
    for row in eachcol(matrix)
        println(join([x == 0 ? "." : string(x) for x in row]))
    end
end

data = load(file_path)
max_clos = 0
it = 0
for i in (1:10000)
    step!.(data, Ref(p_space))
    clos = closeness(data)
    if clos > max_clos
        println("Step $i: $(clos)")
        printmap_small(data, p_space)
        it = i
        max_clos = clos
    end
end

println(max_overlap, "   ", max_it)