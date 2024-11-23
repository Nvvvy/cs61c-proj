.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

    # Prologue

    # check length
    bge x0, a1, exit

    li t0, 0 # index i = 0
    li t1, -99 # running_max is -inf
    li t5, -1 # argmax

loop_start:
    slli t2, t0, 2 # offset of arr address
    add t3, a0, t2 # &a[i] = &a[0] + 4 * i   
    lw t4, 0(t3) # get current value of a[i]
    bge t1, t4, loop_continue # if running_max >= a[i], do nothing
    mv t5, t0 # update argmax
    mv t1, t4 # update running_max

loop_continue:
    addi t0, t0, 1
    blt t0, a1, loop_start

loop_end:
    mv a0, t5
    # Epilogue

    ret

exit:
    li a1, 77
    jal exit2