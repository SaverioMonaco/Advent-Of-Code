"""
--- Day 2: Red-Nosed Reports ---

Fortunately, the first location The Historians want to search isn't a long walk 
from the Chief Historian's office.

While the Red-Nosed Reindeer nuclear fusion/fission plant appears to contain 
no sign of the Chief Historian, the engineers there run up to you as soon as 
they see you. Apparently, they still talk about the time Rudolph was saved 
through molecular synthesis from a single electron.

They're quick to add that - since you're already here - they'd really 
appreciate your help analyzing some unusual data from the Red-Nosed reactor. 
You turn to check if The Historians are waiting for you, but they seem to have 
already divided into groups that are currently searching every corner of the 
facility. You offer to help with the unusual data.

The unusual data (your puzzle input) consists of many reports, one report per 
line. Each report is a list of numbers called levels that are separated by 
spaces. For example:

7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9

This example data contains six reports each containing five levels.

The engineers are trying to figure out which reports are safe. The Red-Nosed 
reactor safety systems can only tolerate levels that are either gradually 
increasing or gradually decreasing. So, a report only counts as safe if both 
of the following are true:

    The levels are either all increasing or all decreasing.
    Any two adjacent levels differ by at least one and at most three.

In the example above, the reports can be found safe or unsafe by checking 
those rules:

    7 6 4 2 1: Safe because the levels are all decreasing by 1 or 2.
    1 2 7 8 9: Unsafe because 2 7 is an increase of 5.
    9 7 6 2 1: Unsafe because 6 2 is a decrease of 4.
    1 3 2 4 5: Unsafe because 1 3 is increasing but 3 2 is decreasing.
    8 6 4 4 1: Unsafe because 4 4 is neither an increase or a decrease.
    1 3 6 7 9: Safe because the levels are all increasing by 1, 2, or 3.

So, in this example, 2 reports are safe.

Analyze the unusual data from the engineers. How many reports are safe?
"""

import DelimitedFiles: readdlm

# The levels are either all increasing or all decreasing.
function rule1(report::Vector{Int})
    sorted_report = sort(report)
    if report == sorted_report
        return true
    elseif report == reverse(sorted_report)
        return true
    else
        return false
    end
end

# Any two adjacent levels differ by at least one and at most three.
function rule2(report::Vector{Int})
    diff_report :: Vector{Int} = zeros(length(report)-1)
    for i in 1:length(report)-1
        diff_report[i] = abs(report[i+1] - report[i])
    end
    
    max_diff = maximum(diff_report)
    min_diff = minimum(diff_report)

    if max_diff < 4
        if min_diff > 0
            return true
        else
            return false
        end
    else
        return false
    end
end

# Load the txt file 
data = readdlm("./data/day2.txt")

n_safe :: Int = 0

for report in eachrow(data)
    clean_report = filter(x -> x != "", report)
    clean_report = convert(Array{Int}, clean_report)
    if rule1(clean_report)
        if rule2(clean_report)
            n_safe += 1
        end
    end
end

print("The number of safe reports are $(n_safe)")