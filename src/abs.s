.globl abs

.text
# =================================================================
# FUNCTION: Given an int return its absolute value.
# Arguments:
# 	a0 (int) is input integer
# Returns:
#	a0 (int) the absolute value of the input
# =================================================================
abs:
    # Prologue
    
    bge a0, zero, done
    sub a0, zero, a0
    done:
    # Epilogue

    ret
