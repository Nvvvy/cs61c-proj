.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # verify args number
    li t0, 5
    bne a0, t0, argc_err

    addi sp, sp, -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)
    sw ra, 48(sp)

    mv s1, a1
    mv s2, a2

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    li a0, 4
    jal malloc
    mv s3, a0
    li a0, 4
    jal malloc
    mv s4, a0

    lw a0, 4(s1) # m0_path = argc[1]
    mv a1, s3 # set m0 rows pointer
    mv a2, s4 # set m0 cols pointer
    jal read_matrix
    mv s5, a0 # s5: m0 pointer

    # Load pretrained m1
    li a0, 4
    jal malloc
    mv s6, a0
    li a0, 4
    jal malloc
    mv s7, a0

    lw a0, 8(s1) # m1_path = argc[2]
    mv a1, s6 # set m1 rows pointer
    mv a2, s7 # set m1 cols pointer
    jal read_matrix
    mv s8, a0 # s8: m1 pointer

    # Load input matrix
    li a0, 4
    jal malloc
    mv s9, a0
    li a0, 4
    jal malloc
    mv s10, a0

    lw a0, 12(s1) # input_path = argc[3]
    mv a1, s9 # input rows pointer
    mv a2, s10 # input cols pointer
    jal read_matrix
    mv s11, a0 # s11: input matrix pointer

    # =====================================
    # RUN LAYERS
    # =====================================
    
    # 1. LINEAR LAYER:    m0 * input , size = m0_rows * input_cols
    # malloc for matmul matrix, s0 as ptr
    lw t0, 0(s3)
    lw t1, 0(s10)
    mul a0, t0, t1
    slli a0, a0, 2
    jal malloc
    beq a0, zero, malloc_err
    mv s0, a0
    # call matmul
    mv a0, s5
    lw a1, 0(s3)
    lw a2, 0(s4)
    mv a3, s11
    lw a4, 0(s9)
    lw a5, 0(s10)
    mv a6, s0
    jal matmul

    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    mv a0, s0
    lw t0, 0(s3)
    lw t1, 0(s10)
    mul a1, t0, t1
    jal relu

    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input), size = m1_rows * s0_cols(i.e. input_cols)
    # free m0
    mv a0, s5
    jal free
    mv a0, s4
    jal free

    # malloc for scores matrix
    lw t0, 0(s6)
    lw t1, 0(s10)
    mul a0, t0, t1
    slli a0, a0, 2
    jal malloc
    beq a0, zero, malloc_err
    mv s5, a0 # s5: scores ptr

    # call matmul
    mv a0, s8
    lw a1, 0(s6)
    lw a2, 0(s7)
    mv a3, s0
    lw a4, 0(s3)
    lw a5, 0(s10)
    mv a6, s5
    jal matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a0, 16(s1) # # output_path = argc[4]
    mv a1, s5 # scores
    lw a2, 0(s6) # m1 rows
    lw a3, 0(s10) # input cols
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s5
    lw t0, 0(s3) # m1 rows
    lw t1, 0(s10) # input cols
    mul a1, t0, t1
    jal argmax
    mv s4, a0
    mv a1, a0

    # Print classification
    bne s2, zero, done
    jal print_int
    # Print newline afterwards for clarity
    li a1 '\n'
    jal print_char

done:
    # free matrices and ptrs
    mv a0, s0
    jal free
    mv a0, s3
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free
    mv a0, s10
    jal free
    mv a0, s11
    jal free

    mv a0, s4 # set ret val

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    lw ra, 48(sp)
    addi sp, sp, 52
    
    ret

malloc_err:
    li a1, 88
    jal exit2

argc_err:
    li a1, 89
    jal exit2