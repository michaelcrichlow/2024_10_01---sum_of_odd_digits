package test

import "core:fmt"
import "core:mem"
import "core:strconv"
import "core:strings"
print :: fmt.println
printf :: fmt.printf

DEBUG_MODE :: true

main :: proc() {

	when DEBUG_MODE {
		// tracking allocator
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf(
					"=== %v allocations not freed: context.allocator ===\n",
					len(track.allocation_map),
				)
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf(
					"=== %v incorrect frees: context.allocator ===\n",
					len(track.bad_free_array),
				)
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}

		// tracking temp_allocator
		track_temp: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track_temp, context.temp_allocator)
		context.temp_allocator = mem.tracking_allocator(&track_temp)

		defer {
			if len(track_temp.allocation_map) > 0 {
				fmt.eprintf(
					"=== %v allocations not freed: context.temp_allocator ===\n",
					len(track_temp.allocation_map),
				)
				for _, entry in track_temp.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track_temp.bad_free_array) > 0 {
				fmt.eprintf(
					"=== %v incorrect frees: context.temp_allocator ===\n",
					len(track_temp.bad_free_array),
				)
				for entry in track_temp.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track_temp)
		}
	}

	// main work
	print("Hello from Odin!")
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

int_cast :: proc {
	int_cast_rune_to_int,
	int_cast_string_to_int,
}

int_cast_rune_to_int :: proc(r: rune) -> (int, bool) {
	if r == '0' do return 0, true
	else if r == '1' do return 1, true
	else if r == '2' do return 2, true
	else if r == '3' do return 3, true
	else if r == '4' do return 4, true
	else if r == '5' do return 5, true
	else if r == '6' do return 6, true
	else if r == '7' do return 7, true
	else if r == '8' do return 8, true
	else if r == '9' do return 9, true
	else do return -1, false
}

int_cast_string_to_int :: proc(s: string) -> (int, bool) {
	val, ok := strconv.parse_int(s)
	return val, ok

}

// overloaded function
// for now just calls one function
str :: proc {
	str_int_to_string,
}

str_int_to_string :: proc(n: int, allocator := context.allocator) -> string {
	b := strings.builder_make(allocator)
	strings.write_int(&b, n)
	final_string := strings.to_string(b)

	return final_string
}

/*
def sum_of_odd_digits(n: int) -> int:
    n_as_string = str(n)
    n_as_list_of_ints = [int(x) for x in n_as_string]
    sum = 0
    for val in n_as_list_of_ints:
        if val % 2 != 0:
            sum += val
    return sum
*/
