.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)

    # check length
    li s0, 1
    blt a1, s0, exit

    addi s0, zero, 0 # s0 as index i
    addi s1, zero, 0 # s1 as num, i.e. arr[i]

loop_start:
    slli s2, s0, 2 # offset of address
    add s3, s2, a0 # &a[i] = &a[0] + i * 4
    lw s1, 0(s3) # get current value of a[i]
    bge s1, zero, loop_continue # if a[i] >= 0, continue
    sw zero, 0(s3) # if a[i] < 0 : a[i] = 0

loop_continue:
    addi s0, s0, 1
    blt s0, a1, loop_start

loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16

	ret

exit:
    li a1, 78
    jal exit2