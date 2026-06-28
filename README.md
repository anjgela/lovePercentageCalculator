# ♥♥♥ Love Percentage Calculator ♥♥♥

A MS-DOS program written in 16-bit 8086 Assembly.
This interactive application calculates the "love compatibility" between two names using the classic paper-and-pencil algorithm.

## The Algorithm

1. **Letter Counting:** Scanning both names to count how many times each unique letter appears.
2. **Folding and Summing:** Summing the first and last digits of the sequence, moving towards the centre at each calculation.
    * If a sum results in a number > 9, it is split into separate digits in the new sequence.
    * If the sequence results in having an odd length, the middle number is carried down as is.
3. **Iteration:** This process repeats, generating a shorter sequence after each iteration.
4. **Stop Condition:** The loop stops once the sequence is:
    * Reduced to exactly 2 digits.
    * Exactly 100.

## Requirements

To compile and run this program, you will need a 16-bit MS-DOS environment:
* **EMU8086**
* **DOSBox** with Turbo Assembler (TASM) or Microsoft Macro Assembler (MASM).

### Compiling with TASM inside DOSBox

If you are using TASM inside DOSBox, mount your directory and run the following commands:

Assemble the code to create the object file:
```bat
tasm love.asm
```
Link the object file to create the executable:
```bat
tlink love.obj
```
Run the application:
```bat
love.exe
```

## Controls
  * [A-Z] / [a-z]: Type the names.
  * [Backspace]: Erase the last typed character.
  * [Enter]: Confirm the name.
  * Y / N: Choose whether to calculate a new percentage at the end of a run.

## Technical Details
  * Architecture: Intel 8086 (16-bit)
  * Interrupts Used:
    * INT 21h / AH=09h (Print string)
    * INT 21h / AH=08h (Read character without echo - used for safe backspacing)
    * INT 21h / AH=02h (Print single character)
    * INT 21h / AH=4Ch (Exit program)
  * Memory Models:
    * Custom data
    * stack
    * code segments.
