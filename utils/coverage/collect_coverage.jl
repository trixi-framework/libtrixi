using Coverage

# process '*.cov' files
# defaults to src/; alternatively, supply the folder name as argument
coverage = process_folder() 

# useful if you want to analyze more than just src/
#coverage = append!(coverage, process_folder("deps"))  

# process '*.info' files, if you collected them
# coverage = merge_coverage_counts(coverage)

# write '*.info' files, if you need them
# LCOV.writefile("lcov.info", coverage)

#  VSCode: Coverage Gutters
#  genhtml --ignore-errors negative -o coverage --title='Trixi' --num-spaces=4 --prefix='./Trixi.jl' lcov.info

# Get total coverage for all Julia files
@show covered_lines, total_lines = get_summary(coverage)

# Cleanup
#clean_folder("src/")
#clean_folder("test/")
#clean_folder("examples/")
