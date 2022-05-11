#!/usr/bin/env python3

import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-x",
        type=int,
        required=True,
        dest="clients",
        help="Number of clients",
    )

    parser.add_argument(
        "-m",
        type=str,
        required=True,
        nargs="*",
        dest="machines",
        help="The (symbolic) identifiers of the machines",
    )

    parser.add_argument(
        "-i",
        type=int,
        required=True,
        dest="start_id",
        help="The starting identifier to assign to the process",
    )

    parser.add_argument(
        "-c",
        type=int,
        required=True,
        dest="client",
        help="The identifier of the client to generate the data for",
    )

    results = parser.parse_args()

    # Assign in round-robin fashion
    for identifier in range(results.clients):
        machine = identifier % len(results.machines)
        if identifier == results.client:
            print("{} {}".format(identifier + results.start_id, results.machines[machine]))
            exit(0)
    
    exit(1)