#!/usr/bin/env python3

import argparse
import sys

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-c",
        type=str,
        required=True,
        dest="cores",
        help="Comma-separated list of cores",
    )

    parser.add_argument(
        "-n",
        type=int,
        required=False,
        dest="number",
        help="How many to pick from the list",
    )

    parser.add_argument(
        "--count",
        required=False,
        action="store_true",
        dest="count",
        help="Count the cores in the list of cores",
    )

    results = parser.parse_args()

    cores = results.cores.split(",")
    for c in cores:
        if c != c.strip():
            print("Parsing error in the cores", file=sys.stderr)
            exit(1)
        
        try: 
            int(c)
        except ValueError:
            print("Parsing error in the cores", file=sys.stderr)
            exit(1)
    
    if results.count:
        if results.number is not None:
            number = max(0, min(results.number, len(cores)))
            print(number)
        else:
            print(len(cores))
        exit(0)

    number = max(0, min(results.number, len(cores)))
    print(",".join(cores[:number]))
