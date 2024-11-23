.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp) # counter of loop
    sw ra, 28(sp)


    # save original args to s registers
    mv s0, a0
    mv s1, a1
    mv s2, a2

    # open binary file with fopen
    mv a1, s0
    li a2, 0 # permission mode: read
    jal fopen
    li t0, -1
    beq a0, t0, fopen_err # if fopen returns -1, exit
    mv s3, a0 # s3: the file pointer

    # malloc for a 8 bytes buffer
    li a0, 8 # buffer size: 8 bytes
    jal malloc
    beq a0, zero, malloc_err
    mv s4, a0 # s4: buffer address

    # get dimensions of matrix with fread
    mv a1, s3
    mv a2, s4
    li a3, 8
    jal fread
    li t0, 8
    bne a0, t0, fread_err # if bytes readed != 8, exit
    lw t1, 0(s4)
    sw t1, 0(s1) # s1: rows
    lw t2, 4(s4)
    sw t2, 0(s2) # s2: cols
    mul s5, t1, t2 # total size: cols * rows

    # malloc for matrix
    slli s5, s5, 2
    mv a0, s5 # malloc total size
    jal malloc
    beq a0, zero, malloc_err
    mv s0, a0 # s0: matrix base address
   
    li s6, 0  # setup counter for loop
    srli s5, s5, 2

loop:
    # call fread to read 4 bytes for one entry of matrix
    mv a1, s3
    mv a2, s4
    li a3, 4
    jal fread
    li t0, 4
    bne a0, t0, fread_err # if bytes != 4, exit

    # calculate the offset of matrix base address
    slli t0, s6, 2
    add t0, t0, s0 # get &matrix[i]
    lw t1, 0(s4)
    sw t1, 0(t0) # save bytes in buffer to &matrix[i]
    addi s6, s6, 1
    blt s6, s5, loop

    # call fclose
    mv a1, s3
    jal fclose
    bne a0, zero, fclose_err

    # free buffer
    mv a0, s4
    jal free

    # Epilogue
    mv a0, s0 # set retrun value

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32

    ret

malloc_err:
    li a1, 88
    jal exit2

fopen_err:
    li a1, 90
    jal exit2

fread_err:
    li a1, 91
    jal exit2

fclose_err:
    li a1, 92
    jal exit2