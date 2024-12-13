"""
--- Day 13: Claw Contraption ---

Next up: the lobby of a resort on a tropical island. The Historians take a 
moment to admire the hexagonal floor tiles before spreading out.

Fortunately, it looks like the resort has a new arcade! Maybe you can win some 
prizes from the claw machines?

The claw machines here are a little unusual. Instead of a joystick or 
directional buttons to control the claw, these machines have two buttons 
labeled A and B. Worse, you can't just put in a token and play; it costs 3 
tokens to push the A button and 1 token to push the B button.

With a little experimentation, you figure out that each machine's buttons are 
configured to move the claw a specific amount to the right (along the X axis) 
and a specific amount forward (along the Y axis) each time that button is 
pressed.

Each machine contains one prize; to win the prize, the claw must be positioned 
exactly above the prize on both the X and Y axes.

You wonder: what is the smallest number of tokens you would have to spend to 
win as many prizes as possible? You assemble a list of every machine's button 
behavior and prize location (your puzzle input). For example:

Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279

This list describes the button configuration and prize location of four 
different claw machines.

For now, consider just the first claw machine in the list:

    Pushing the machine's A button would move the claw 94 units along the X axis 
    and 34 units along the Y axis.

    Pushing the B button would move the claw 22 units along the X axis and 67 
    units along the Y axis.

    The prize is located at X=8400, Y=5400; this means that from the claw's 
    initial position, it would need to move exactly 8400 units along the X axis 
    and exactly 5400 units along the Y axis to be perfectly aligned with the prize 
    in this machine.

The cheapest way to win the prize is by pushing the A button 80 times and the 
B button 40 times. This would line up the claw along the X axis (because 80*94 
+ 40*22 = 8400) and along the Y axis (because 80*34 + 40*67 = 5400). Doing 
this would cost 80*3 tokens for the A presses and 40*1 for the B presses, a 
total of 280 tokens.

For the second and fourth claw machines, there is no combination of A and B 
presses that will ever win a prize.

For the third claw machine, the cheapest way to win the prize is by pushing 
the A button 38 times and the B button 86 times. Doing this would cost a total 
of 200 tokens.

So, the most prizes you could possibly win is two; the minimum tokens you 
would have to spend to win all (two) prizes is 480.

You estimate that each button would need to be pressed no more than 100 times 
to win a prize. How else would someone be expected to play?

Figure out how to win as many prizes as possible. What is the fewest tokens 
you would have to spend to win all possible prizes?
"""

struct Problem
    A :: Tuple{Int, Int}
    B :: Tuple{Int, Int}
    cord_prize :: Tuple{Int, Int}
end

function solve(problem::Problem)
    # Get the increments for the buttons and the prize coordinates
    A = problem.A
    B = problem.B
    prize = problem.cord_prize

    # Brute-force search for the number of presses (from -100 to 100, or some reasonable range)
    min_cost = Inf
    best_A_presses = 0
    best_B_presses = 0

    # Try all combinations of A_n_press and B_n_press in a reasonable range
    for A_n_press in -100:100
        for B_n_press in -100:100
            # Calculate the resulting prize coordinates from the current button presses
            resulting_x = A_n_press * A[1] + B_n_press * B[1]
            resulting_y = A_n_press * A[2] + B_n_press * B[2]

            # Check if this results in the correct prize coordinates
            if resulting_x == prize[1] && resulting_y == prize[2]
                # Calculate the cost
                cost = 3 * A_n_press + B_n_press
                if cost < min_cost
                    min_cost = cost
                    best_A_presses = A_n_press
                    best_B_presses = B_n_press
                end
            end
        end
    end

    if isinf(min_cost)
        return 0
    else
        return min_cost
    end
end

function load_p_Problem(path::String)
    # Load and separate into each problem description
    p_problem_raw = reshape(readlines(path), 4, :)

    # Regex patterns
    button_regex = r"Button \w+: X\+(\d+), Y\+(\d+)"
    prize_regex = r"Prize: X=(\d+), Y=(\d+)"
    
    p_Problem = []
    for problem_raw in eachcol(p_problem_raw)
        # Extract button increments
        button_A = match(button_regex, problem_raw[1])
        button_B = match(button_regex, problem_raw[2])
        prize = match(prize_regex, problem_raw[3])

        if button_A !== nothing && button_B !== nothing && prize !== nothing
            # Parse values into integers and structure the data
            button_A_increments = (parse(Int, button_A[1]), parse(Int, button_A[2]))
            button_B_increments = (parse(Int, button_B[1]), parse(Int, button_B[2]))
            prize_coordinates = (parse(Int, prize[1]), parse(Int, prize[2]))

            # Store the problem description in a structured format (e.g., dictionary or tuple)
            push!(p_Problem, Problem(button_A_increments, button_B_increments, prize_coordinates))
        end
    end

    return p_Problem
end

# Example usage:
file_path = "./data/day13.txt"
data = load_p_Problem(file_path)

# Solve for the first problem
cost = sum(solve.(data))
println("Minimum cost: $cost")

"""
--- Part Two ---

As you go to win the first prize, you discover that the claw is nowhere near 
where you expected it would be. Due to a unit conversion error in your 
measurements, the position of every prize is actually 10000000000000 higher on 
both the X and Y axis!

Add 10000000000000 to the X and Y position of every prize. After making this 
change, the example above would now look like this:

Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=10000000008400, Y=10000000005400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=10000000012748, Y=10000000012176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=10000000007870, Y=10000000006450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=10000000018641, Y=10000000010279

Now, it is only possible to win a prize on the second and fourth claw machines
. Unfortunately, it will take many more than 100 presses to do so.

Using the corrected prize coordinates, figure out how to win as many prizes as 
possible. What is the fewest tokens you would have to spend to win all 
possible prizes?
"""

shift = 10000000000000

function load_p_Problem2(path::String)
    # Load and separate into each problem description
    p_problem_raw = reshape(readlines(path), 4, :)

    # Regex patterns
    button_regex = r"Button \w+: X\+(\d+), Y\+(\d+)"
    prize_regex = r"Prize: X=(\d+), Y=(\d+)"
    
    p_Problem = []
    for problem_raw in eachcol(p_problem_raw)
        # Extract button increments
        button_A = match(button_regex, problem_raw[1])
        button_B = match(button_regex, problem_raw[2])
        prize = match(prize_regex, problem_raw[3])

        if button_A !== nothing && button_B !== nothing && prize !== nothing
            # Parse values into integers and structure the data
            button_A_increments = (parse(Int, button_A[1]), parse(Int, button_A[2]))
            button_B_increments = (parse(Int, button_B[1]), parse(Int, button_B[2]))
            prize_coordinates = (parse(Int, prize[1])+shift, parse(Int, prize[2])+shift)

            # Store the problem description in a structured format (e.g., dictionary or tuple)
            push!(p_Problem, Problem(button_A_increments, button_B_increments, prize_coordinates))
        end
    end

    return p_Problem
end

function solve2(problem::Problem)
    # To formalize it mathematically, I have:
    # problem.cord_prize : a 2D point, let's call it P
    # a vector problem.A, let's call it A
    # a vector problem.B, let's call it B
    # 
    # I want to find the scalars a and b such that 
    #     a*A + b*B = P
    # 
    # This is equivalent to solve M x = P where M is the 
    # matrix of the vectors A and B
    # x = M(-1)P
    # 
    #
    # The inverse of the determinant in the inverse matrix M
    inv_determinant = 1/(problem.A[1]*problem.B[2] - problem.A[2]*problem.B[1]) 
    
    n_A = round(inv_determinant*(problem.B[2]*problem.cord_prize[1] - problem.B[1]*problem.cord_prize[2]))
    n_B = round(inv_determinant*(problem.A[1]*problem.cord_prize[2] - problem.A[2]*problem.cord_prize[1]))

    if (n_A .* problem.A) .+ (n_B .* problem.B) == problem.cord_prize
        println("YES $problem")
        return 3*n_A + n_B
    else
        println("NO  $problem")
        return 0
    end

end

# Example usage:
data = load_p_Problem2(file_path)

# Solve for the first problem
cost = sum(solve2.(data))
println("\nMinimum cost:")
println(BigInt(cost))