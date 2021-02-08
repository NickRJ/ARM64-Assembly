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
    mov    x1, sp           // pointer to end of string
    sub    sp, sp, 32       // allocate 32 bytes of stack space, use to store chars

    mov    w0, 1234
    bl     int_to_str       // call int_to_str()
    str    x0, [sp]         // store pointer on stack

    bl     strlen           // call strlen() on returned string
    str    x0, [sp, 8]      // store length on stack

                            // syscall args:
    mov    x0, 1            // stdout
    ldr    x1, [sp]         // pointer to first char
    ldr    x2, [sp, 8]      // string length
    mov    x8, 64
    svc    0                // print to stdout

    add    sp, sp, 32       // deallocate stack

    mov    x8, 93           
    svc    0                // exit program


// strlen(const char* str)
// increments length until null-terminator reached
// returns length of string
strlen:
    mov    x1, -1           // init length

.str_loop:
    add    x1, x1, 1        // increment length
    ldr    w2, [x0, x1]     // w2 = str[x1]
    cmp    w2, 0
    bne    .str_loop

    mov    x0, x1           // return
    ret


// modulo(int n, int d)
// n % d = n - ((n / d) * d)
// returns n % d
modulo:
    mov    w8, w0           // store n in temp
    sdiv   w0, w0, w1       // w0 = n / d
    mul    w0, w0, w1       // w0 *= d
                            // can Rd and Rm be the same? apparently so
                            // was not supported in earlier ARM versions
    sub    w0, w8, w0       // w4 = n - w4
    ret                     // return from function: set pc to address in link register


// int_to_str(int n, char* str_end)
// returns pointer to first char
int_to_str:
    stp    x29, x30, [sp, -48]!     // store fp, lp, allocate 48 bytes of stack space
    str    x21, [sp, 32]            // store callee-saved registers
    stp    x19, x20, [sp, 16]       

                            // store arguments
    mov    w19, w0          // input
    mov    x20, x1          // pointer to end of string
    mov    w21, 10          // divisor

    mov    w8, 0
    strb   w8, [x20, -1]!   // push null terminator to stack
    mov    w8, 10
    strb   w8, [x20, -1]!   // push newline char '\n' to stack

// compute LSD, push to stack
.push_digit:
    mov    w0, w19          // args to modulo subroutine
    mov    w1, w21
    bl     modulo           // call modulo() to compute n % 10
                            // set link register (x30) to next instruction & branch to function

    add    w0, w0, 48       // convert single digit to ascii: add '0'
    strb   w0, [x20, -1]!   // push ascii digit to stack

    sdiv   w19, w19, w21    // n //= 10
    cmp    w19, 0           // keep looping until n == 0
    bne    .push_digit

    mov    x0, x20          // return pointer to first char

    ldp    x19, x20, [sp, 16]       // restore callee-saved registers
    ldr    x21, [sp, 32]
    ldp    x29, x30, [sp], 48       // restore fp, lp, deallocate stack

    ret                     
