def sum_of_odd_digits(n: int) -> int:
    n_as_string = str(n)
    n_as_list_of_ints = [int(x) for x in n_as_string]
    sum = 0
    for val in n_as_list_of_ints:
        if val % 2 != 0:
            sum += val
    return sum


def main() -> None:
    print(sum_of_odd_digits(12345))


if __name__ == '__main__':
    main()
