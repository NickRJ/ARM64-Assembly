// challenge: convert 32-bit unsigned int to string and print to stdout

// store each digit on stack:
// compute least-significant digit (LSD) with n % 10
// push LSD + '0' to stack
// divide n by 10: n /= 10
// repeat until n == 0

.arch armv8-a
.global _start
.text

_start:
    mov    w0, 1234         // integer to convert to string
    mov    w1, 10           // divisor

    sub    sp, sp, 16       // allocate 16 bytes of stack space, use as stack to store chars
                            // push each char inside stack
                            // enough to store max 10 digits + '\n' + '\0'
    mov    w9, 0          
    strb   w9, [sp, 15]     // push null terminator at sp+15
    mov    w9, 10
    strb   w9, [sp, 14]     // push newline char '\n' at sp+14

    mov    w2, 2            // current length of string
    mov    x3, 13           // stack offset; store current char in sp + offset

    b      push_digits


// compute LSD, store on stack
// args: w0: numerator, w1: divisor, w2: length
push_digits:
    bl     modulo           // compute w0 % 10, store result in w4
                            // set link register (x30) to next instruction & branch to function

    add    w4, w4, 48       // convert single digit to ascii: add '0'
    strb   w4, [sp, x3]     // push w4 to stack
    sub    x3, x3, 1        // decrement stack offset, making room for next char
    add    w2, w2, 1        // increment length
    
    sdiv   w0, w0, w1       // w0 //= 10
    cmp    w0, 0            // if w0 == 0, end
    beq    end

    b      push_digits      // keep looping on each digit


// compute modulo
// R = N - ((N / D) * D)
// args: w0: numerator (N), w1: divisor (D)
// returns: w4
modulo:
    sdiv   w4, w0, w1       // w4 = N / 10
    mul    w4, w4, w1       // w4 *= 10
                            // can Rd and Rm be the same? apparently so
                            // was not supported in earlier ARM versions
    sub    w4, w0, w4       // w4 = N - w4

    ret                     // return from function: set pc to address in link register


// print integer stored on stack
end:
    mov    x0, 1            // syscall args
    add    x3, x3, 1        // calculate pointer to first char
    add    x1, sp, x3      
    mov    x8, 64
    svc    0                // print stdout

    add    sp, sp, 16       // deallocate stack

    mov    x8, 93           // exit program
    svc    0
