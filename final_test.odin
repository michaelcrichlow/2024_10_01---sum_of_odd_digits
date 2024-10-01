package test

import "core:fmt"
import "core:mem"
print :: fmt.println
printf :: fmt.printf

main :: proc() {

	print(sum_of_odd_digits(12345, context.temp_allocator))
	free_all(context.temp_allocator)
}

sum_of_odd_digits :: proc(n: int, allocator := context.allocator) -> int {
	n_as_string := str(n, allocator)

	n_as_list_of_ints: [dynamic]int
	defer delete(n_as_list_of_ints)

	for val in n_as_string {
		if val_as_int, ok := int_cast(val); ok {
			append(&n_as_list_of_ints, val_as_int)
		}
	}

	sum := 0
	for val in n_as_list_of_ints {
		if val % 2 != 0 {
			sum += val
		}
	}

	return sum
}
