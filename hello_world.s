// print "Hello World" to stdout
// x0, x1, x2: function parameters to linux write syscall
// x8: linux syscall number - syscalls are how programs interface with an OS

// full list of linux syscalls: 
// https://github.com/torvalds/linux/blob/master/include/uapi/asm-generic/unistd.h

.arch armv8-a
.global _start

_start:
    mov    x0, 1        // stdout 
    ldr    x1, =hello   // pointer to string
    mov    x2, 12       // string length

    mov    x8, 64       // SYS_write syscall
    svc    0            // tell linux to output string

    mov    x8, 93       // SYS_exit syscall
    svc    0            // tell linux to terminate program

.data
hello: .ascii "Hello World\n"
