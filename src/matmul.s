.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    bge zero, a1, m0_dimensions_err
    bge zero, a2, m0_dimensions_err
    bge zero, a4, m1_dimensions_err
    bge zero, a5, m1_dimensions_err
    bne a2, a4, mat_match_err # if m0_cols != m1_rows, quit

    # Prologue
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp) # i, row of ret matrix
    sw s1, 8(sp) # j, column of ret matrix
    sw s2, 12(sp) # entry_val
    sw s3, 16(sp) # ret_matrix_entry address
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)


    li s0, 0 # i < m0_rows i.e. a1
    mv s3, a6
    mv s4, a0 # save args since call dot func will overwrite these
    mv s5, a1
    mv s6, a2
    mv s7, a3
    mv s8, a4
    mv s9, a5

    
# increment m0_rows i, i.e s0
outer_loop_start:
    bge s0, s5, outer_loop_end
    li s1, 0 # reset ret_matrix_col j to 0, j < m1_cols i.e. a5

# increment m1_cols j, i.e s1
inner_loop_start:
    bge s1, s9, inner_loop_end

    # get the address of horizontal v0 and vertical v1
    # &v0[0] = &m0[0] + 4 * m0_col * i
    # &v1[0] = &m1[0] + 4 * j
    mul a0, s6, s0 # m0_col * i
    slli a0, a0, 2
    add a0, a0, s4
    slli a1, s1, 2
    add a1, a1, s7

    mv a2, s6 # length of vector is m0_col
    li a3, 1 # stride of v0 is 1, since It's horizontal
    mv a4, s9# stride of v1 is the columns of m1(i.e. a5), since It's vertical

    jal dot # call dot function to calculate each entry
    mv s2, a0 # save entry_val to s2


    sw s2, 0(s3)
    addi s3, s3, 4

    addi s1, s1, 1 # j++
    j inner_loop_start

inner_loop_end:
    addi s0, s0, 1 # i++
    j outer_loop_start


outer_loop_end:
    # Epilogue
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    addi sp, sp, 44

    ret

m0_dimensions_err:
    li a1, 72
    jal exit2

m1_dimensions_err:
    li a1, 73
    jal exit2

mat_match_err:
    li a1, 74
    jal exit2