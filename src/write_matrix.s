.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)

    # save args
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # open file with fopen
    mv a1, s0
    li a2, 1
    jal fopen
    li t0, -1
    beq a0, t0, fopen_err
    mv s0, a0 # s0 is the file pointer

    # malloc for a 8 bytes buffer
    li a0, 8
    jal malloc
    mv s4, a0 # s4 is the 8 bytes buffer

    # write rows and cols to file
    sw s2, 0(s4)
    sw s3, 4(s4)
    mv a1, s0
    mv a2, s4
    li a3, 2
    li a4, 4
    jal fwrite
    li t0, 2
    bne a0, t0, fwrite_err

    mul s2, s2, s3 # s2 is total elements of matrix
    li s3, 0 # setup s3 as counter

loop:
    # get arr[i]
    slli t0, s3, 2
    add t0, t0, s1
    lw t1, 0(t0) # t1 = arr[i]
    sw t1, 0(s4) # put arr[i] into buffer

    # call fwrite
    mv a1, s0
    mv a2, s4
    li a3, 1 # write 1 element of 4 bytes each time
    li a4, 4
    jal fwrite 
    li t0, 1
    bne a0, t0, fwrite_err # if a0 != 1, exit

    # loop condition
    addi s3, s3, 1
    blt s3, s2, loop

    # call fclose
    mv a1, s0
    jal fclose
    bne a0, zero, fclose_err

    # free buffer
    mv a0, s4
    jal free

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24

    ret

fopen_err:
    li a1, 93
    jal exit2

fwrite_err:
    li a1, 94
    jal exit2

fclose_err:
    li a1, 95
    jal exit2