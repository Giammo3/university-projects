# Architettura degli elaboratori (2023/2024) — Assembly Project

## Project Description

The goal of the project is to implement a **production scheduling system** in **Assembly language (AT&T syntax)**.

The system manages up to **10 products** to be scheduled within **100 time units**.

Each product is defined by:

- ID
- duration
- deadline
- priority

The program reads product data from a text file and allows the user to choose between two scheduling algorithms.

## Scheduling Algorithms

### EDF — Earliest Deadline First
Products with the earliest deadline are scheduled first.  
If two products have the same deadline, the one with higher priority is scheduled first.

### HPF — Highest Priority First
Products with higher priority are scheduled first.  
If two products have the same priority, the one with earlier deadline is scheduled first.

## Output

The program prints:

- the order in which products are scheduled
- the start time of each product
- the completion time of the last product
- the total penalty caused by delays

## Project Structure

- `src/` → Assembly source code
- `orders/` → example input files
- `docs/` → assignment and report
- `Makefile` → instructions to compile the program

## Notes
This project was developed as part of my first year in Computer Science at the University of Verona.
