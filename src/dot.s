.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    bge zero, a2, len_err
    bge zero, a3, stride_err
    bge zero, a4, stride_err

    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)

    li t0, 0 # index i = 0
    li t1, 0 # product of v0 and v1

loop_start:
    slli t2, t0, 2 # i * 4
    mul s2, t2, a3 # stride_v0 * i * 4
    mul s3, t2, a4 # stride_v1 * i * 4

    add s0, a0, s2 # &v0[i]
    add s1, a1, s3 # &v1[i]
    lw t3, 0(s0) # value of v0[i]
    lw t4, 0(s1) # value of v1[i]
    mul t3, t3, t4
    add t1, t1, t3

    addi t0, t0, 1 # i++
    blt t0, a2, loop_start

loop_end:
    mv a0, t1

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16

    ret

stride_err:
    li a1, 76
    jal exit2

len_err:
    li a1, 75
    jal exit2
