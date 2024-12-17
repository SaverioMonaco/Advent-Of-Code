"""
--- Day 17: Chronospatial Computer ---

The Historians push the button on their strange device, but this time, you all 
just feel like you're falling.

"Situation critical", the device announces in a familiar voice. "Bootstrapping 
process failed. Initializing debugger...."

The small handheld device suddenly unfolds into an entire computer! The 
Historians look around nervously before one of them tosses it to you.

This seems to be a 3-bit computer: its program is a list of 3-bit numbers (0 
through 7), like 0,1,2,3. The computer also has three registers named A, B, 
and C, but these registers aren't limited to 3 bits and can instead hold any integer.

The computer knows eight instructions, each identified by a 3-bit number (
called the instruction's opcode). Each instruction also reads the 3-bit number 
after it as an input; this is called its operand.

A number called the instruction pointer identifies the position in the program 
from which the next opcode will be read; it starts at 0, pointing at the first 
3-bit number in the program. Except for jump instructions, the instruction 
pointer increases by 2 after each instruction is processed (to move past the 
instruction's opcode and its operand). If the computer tries to read an opcode 
past the end of the program, it instead halts.

So, the program 0,1,2,3 would run the instruction whose opcode is 0 and pass 
it the operand 1, then run the instruction having opcode 2 and pass it the 
operand 3, then halt.

There are two types of operands; each instruction specifies the type of its 
operand. The value of a literal operand is the operand itself. For example, 
the value of the literal operand 7 is the number 7. The value of a combo 
operand can be found as follows:

    Combo operands 0 through 3 represent literal values 0 through 3.
    Combo operand 4 represents the value of register A.
    Combo operand 5 represents the value of register B.
    Combo operand 6 represents the value of register C.
    Combo operand 7 is reserved and will not appear in valid programs.

The eight instructions are as follows:

The adv instruction (opcode 0) performs division. The numerator is the value 
in the A register. The denominator is found by raising 2 to the power of the 
instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); 
an operand of 5 would divide A by 2^B.) The result of the division operation 
is truncated to an integer and then written to the A register.

The bxl instruction (opcode 1) calculates the bitwise XOR of register B and 
the instruction's literal operand, then stores the result in register B.

The bst instruction (opcode 2) calculates the value of its combo operand 
modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to 
the B register.

The jnz instruction (opcode 3) does nothing if the A register is 0. However, 
if the A register is not zero, it jumps by setting the instruction pointer to 
the value of its literal operand; if this instruction jumps, the instruction 
pointer is not increased by 2 after this instruction.

The bxc instruction (opcode 4) calculates the bitwise XOR of register B and 
register C, then stores the result in register B. (For legacy reasons, this 
instruction reads an operand but ignores it.)

The out instruction (opcode 5) calculates the value of its combo operand 
modulo 8, then outputs that value. (If a program outputs multiple values, they 
are separated by commas.)

The bdv instruction (opcode 6) works exactly like the adv instruction except 
that the result is stored in the B register. (The numerator is still read from 
the A register.)

The cdv instruction (opcode 7) works exactly like the adv instruction except 
that the result is stored in the C register. (The numerator is still read from 
the A register.)

Here are some examples of instruction operation:

    If register C contains 9, the program 2,6 would set register B to 1.
    If register A contains 10, the program 5,0,5,1,5,4 would output 0,1,2.
    If register A contains 2024, the program 0,1,5,4,3,0 would output 4,2,5,6,7,7,7,7,3,1,0 and leave 0 in register A.
    If register B contains 29, the program 1,7 would set register B to 26.
    If register B contains 2024 and register C contains 43690, the program 4,0 would set register B to 44354.

The Historians' strange device has finished initializing its debugger and is 
displaying some information about the program it is trying to run (your puzzle 
input). For example:

Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0

Your first task is to determine what the program is trying to output. To do 
this, initialize the registers to the given values, then run the given program
, collecting any output produced by out instructions. (Always join the values 
produced by out instructions with commas.) After the above program halts, its 
final output will be 4,6,3,5,6,3,5,2,1,0.

Using the information provided by the debugger, initialize the registers to 
the given values, then run the program. Once it halts, what do you get if you 
use commas to join the values it output into a single string?
"""

mutable struct Computer
    A::Int
    B::Int
    C::Int
    program::Vector{Int}
    idx::Int
end

function load(file_path)
    register_regex = r"Register .*: (-?\d+)"
    program_string = "Program: "

    data = readlines(file_path)
    A_register = parse(Int, match(register_regex, data[1])[1])
    B_register = parse(Int, match(register_regex, data[2])[1])
    C_register = parse(Int, match(register_regex, data[3])[1])

    program = parse.(Int, split(data[5][length(program_string)+1:end], ","))

    return A_register, B_register, C_register, program
end
    
function get_operand(computer)
    program_value = computer.program[computer.idx + 1]
    if program_value <= 3 && program_value >= 0
        return program_value
    elseif program_value == 4
        return computer.A
    elseif program_value == 5
        return computer.B
    elseif program_value == 6
        return computer.C
    else
        println("Invalid combo operand $program_value")
        return nothing
    end
end
"""
opcode 0
The adv instruction (opcode 0) performs division. The numerator is the value 
in the A register. The denominator is found by raising 2 to the power of the 
instruction's combo operand. The result of the division operation 
is truncated to an integer and then written to the A register."""
function adv!(computer)
    operand = get_operand(computer)
    if !isnothing(operand)
        numerator = computer.A
        denominator = 2^operand
        
        computer.A = div(numerator, denominator)

        return nothing
    else
        return -1
    end
end

"""
opcode 1
The bxl instruction calculates the bitwise XOR of register B and 
the instruction's literal operand, then stores the result in register B."""
function bxl!(computer)
    operand = computer.program[computer.idx + 1]
    if !isnothing(operand)
        computer.B = xor(computer.B, operand)

        return nothing
    else
        return -1
    end
end

"""
opcode 2
The bst instruction calculates the value of its combo operand 
modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to 
the B register."""
function bst!(computer)
    operand = get_operand(computer)
    if !isnothing(operand)
        computer.B = operand % 8

        return nothing
    else
        return -1
    end
end

"""
opcode 3
The jnz instruction does nothing if the A register is 0. However, 
if the A register is not zero, it jumps by setting the instruction pointer to 
the value of its literal operand; if this instruction jumps, the instruction 
pointer is not increased by 2 after this instruction."""
function jnz!(computer)
    if computer.A != 0
        operand = computer.program[computer.idx + 1]
        if !isnothing(operand)
            computer.idx = operand - 1
        else
            return -1
        end
    end

    return nothing
end

"""
opcode 4
The bxc instruction calculates the bitwise XOR of register B and 
register C, then stores the result in register B. (For legacy reasons, this 
instruction reads an operand but ignores it.)"""
function bxc!(computer)
    # operand = get_operand(computer)
    operand = 0
    if !isnothing(operand)
        computer.B = xor(computer.B, computer.C)

        return nothing
    else
        return -1
    end
end

"""
opcode 5
The out instruction calculates the value of its combo operand 
modulo 8, then outputs that value. (If a program outputs multiple values, they 
are separated by commas.)"""
function out!(computer)
    operand = get_operand(computer)
    if !isnothing(operand)
        result = operand % 8

        return result
    else
        return -1
    end
end

"""
opcode 6
The bdv instruction works exactly like the adv instruction except 
that the result is stored in the B register. (The numerator is still read from 
the A register.)"""
function bdv!(computer)
    operand = get_operand(computer)
    if !isnothing(operand)
        numerator = computer.A
        denominator = 2^operand
        
        computer.B = div(numerator, denominator)

        return nothing
    else
        return -1
    end
end

"""
opcode 7
The cdv instruction (opcode 7) works exactly like the adv instruction except 
that the result is stored in the C register. (The numerator is still read from 
the A register.)"""
function cdv!(computer)
    operand = get_operand(computer)
    if !isnothing(operand)
        numerator = computer.A
        denominator = 2^operand
        
        computer.C = div(numerator, denominator)

        return nothing
    else
        return -1
    end
end

p_f = [adv!, bxl!, bst!, jnz!, bxc!, out!, bdv!, cdv!]

function execute!(computer)
    p_out = []
    while computer.idx < length(computer.program)
        f = p_f[computer.program[computer.idx]+1]
        # println("Applying function $f")
        return_value = f(computer)
        if !isnothing(return_value)
            if return_value < 0
                return p_out
            end
            push!(p_out, return_value)
        end
        computer.idx += 2
    end
    return p_out
end

println("Examples:")
ex_num = 1
# If register C contains 9, the program 2,6 would set register B to 1.
ex1 = Computer(0, 0, 9, [2,6], 1)
println("$ex_num) Before : $ex1")
execute!(ex1)
println("$ex_num) After  : $ex1")
ex_num += 1

# If register A contains 10, the program 5,0,5,1,5,4 would output 0,1,2.
ex2 = Computer(10, 0, 0, [5,0,5,1,5,4], 1)
println("$ex_num) Before : $ex2")
ex2_solution = execute!(ex2)
println("$ex_num) After  : $ex2")
println("$ex_num) Output: $ex2_solution")
ex_num += 1

# If register A contains 2024, the program 0,1,5,4,3,0 would output 4,2,5,6,7,7,7,7,3,1,0 and leave 0 in register A.
ex3 = Computer(2024, 0, 0, [0,1,5,4,3,0], 1)
println("$ex_num) Before : $ex3")
ex3_solution = execute!(ex3)
println("$ex_num) After  : $ex3")
println("$ex_num) Output: $ex3_solution")
ex_num += 1

# If register B contains 29, the program 1,7 would set register B to 26.
ex4 = Computer(0, 29, 0, [1,7], 1)
println("$ex_num) Before : $ex4")
execute!(ex4)
println("$ex_num) After  : $ex4")
ex_num += 1

# If register B contains 2024 and register C contains 43690, the program 4,0 would set register B to 44354.
ex5 = Computer(0, 2024, 43690, [4,0], 1)
println("$ex_num) Before : $ex5")
execute!(ex5)
println("$ex_num) After  : $ex5")

file_path = "./data/day17.txt"
args = load(file_path)
computer = Computer(args[1], args[2], args[3], args[4], 1)

println(computer)
solution = execute!(computer)
println(computer)
println(solution)

"""
--- Part Two ---

Digging deeper in the device's manual, you discover the problem: this program 
is supposed to output another copy of the program! Unfortunately, the value in 
register A seems to have been corrupted. You'll need to find a new value to 
which you can initialize register A so that the program's output instructions 
produce an exact copy of the program itself.

For example:

Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0

This program outputs a copy of itself if register A is instead initialized to 
117440. (The original initial value of register A, 2024, is ignored.)

What is the lowest positive initial value for register A that causes the 
program to output a copy of itself?
"""

# All hail the bruteforce king 

function execute2!(computer)
    solution = computer.program
    sol_idx = 1
    p_out = []
    while computer.idx < length(computer.program)
        f = p_f[computer.program[computer.idx]+1]
        return_value = f(computer)
        if !isnothing(return_value)
            if solution[sol_idx] == return_value
                sol_idx += 1
                push!(p_out, return_value)
            else
                return false
            end
        end
        computer.idx += 2
    end
    return p_out == solution
end

file_path = "./data/day17.txt"
args = load(file_path)
for A in (1:100)
    computer = Computer(A, args[2], args[3], args[4], 1)
    solution = execute!(computer)
    println("$A: $solution | $(length(solution))")
end

# Interesting:
# at A == 1 we have that the length of the solution is 1
# at A == 8 we have that the length of the solution is 2
# at A == 64 we have that the length of the solution is 3
# then i will assume that
# at A == 8^(L-1) - 1 the length will be L-1
# but at A == 8^(L-1) the length will be L

L = length(computer.program)
println("Length of the solution is: $L")
computer = Computer(8^(L-1)-1, args[2], args[3], args[4], 1)
L1 = length(execute!(computer))
computer = Computer(8^(L-1), args[2], args[3], args[4], 1)
L2 = length(execute!(computer))
println("at A == 8^(L-1) - 1 the length is $L1")
println("at A == 8^(L-1)     the length is $L2")

p_A = range(8^(L-1),8^(L))[1:69]
for (i, A) in zip(range(1, length(p_A)), p_A)
    computer = Computer(A, args[2], args[3], args[4], 1)
    solution = execute!(computer)
    println("$i : $A: $solution | $(length(solution))")
end

# This is a bit harder to notice, but the output does not change much 
# only the left most values, new values are added to the changing ones
# every 8 to the power of something 
# 8^(L-1) <-> 8^(L-1) + 8   (only first digit changes)
# 8^(L-1) <-> 8^(L-1) + 8^2 (1 and 2)
# I am going to assume that up until 8^(L-1) + 8^(L-1) the rightmost digit never changes
#
p_A = range(2*8^(L-1)-3,2*8^(L-1)+3)
for (i, A) in zip(range(1, length(p_A)), p_A)
    computer = Computer(A, args[2], args[3], args[4], 1)
    solution = execute!(computer)
    println("$i : $A: $solution | $(length(solution))")
end

# Then i am going to assume that it stays the same up until the next 8^(L-1) entries
p_A = range(3*8^(L-1)-3,3*8^(L-1)+3)
for (i, A) in zip(range(1, length(p_A)), p_A)
    computer = Computer(A, args[2], args[3], args[4], 1)
    solution = execute!(computer)
    println("$i : $A: $solution | $(length(solution))")
end

# I will test this i have no idea if this is correct
# I am starting from 8^(L-1)
# I add 8^(L-1) until the right most digit is the right one
# Then I add 8^(L-2) to do the same but for the one before the last one
function get_A(p_k)
    A = 0
    for (idx_k, k) in zip(range(1,length(p_k)), p_k)
        A += k*8^(idx_k-1)
    end
    return A
end

p_k = repeat([0], length(args[4]))
p_k[end] = 1
computer = Computer(get_A(p_k), args[2], args[3], args[4], 1)

for idx_k in reverse(range(1,length(p_k)))
    println(idx_k)
    while true
        sleep(0.3)
        A = get_A(p_k)
        computer = Computer(A, args[2], args[3], args[4], 1)
        solution = execute!(computer)
        println(A, "  ", solution)
        sleep(.3)
        if idx_k > 1 && idx_k < 15 && computer.program[idx_k + 1] != solution[idx_k + 1]
            println("WAAA")
            p_k[idx_k+1] -= 1
            p_k[idx_k] = 0
            A = get_A(p_k)
            computer = Computer(A, args[2], args[3], args[4], 1)
            while computer.program[idx_k] != solution[idx_k]
                A = get_A(p_k)
                computer = Computer(A, args[2], args[3], args[4], 1)
                solution = execute!(computer)
                p_k[idx_k] += 1
            end
        end
        if computer.program[idx_k] == solution[idx_k]
            println("Found $idx_k = $(p_k[idx_k])")
            break
        else
            p_k[idx_k] += 1
        end
    end
end
p_k[1:9] .= 0
start_A = get_A(p_k)
computer = Computer(A, args[2], args[3], args[4], 1)
solution = execute!(computer)
println(solution, "  ", args[4])

for A in range(start_A, 8^L)
    computer = Computer(A, args[2], args[3], args[4], 1)
    if execute2!(computer)
        println("Found A: $A")
    end
end