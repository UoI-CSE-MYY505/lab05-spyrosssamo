.data
storage:
    .word 1
    .word 10
    .word 11

.text
# ----------------------------------------------------------------------------------------
# Prepare register values
# ----------------------------------------------------------------------------------------
    la   a0, storage
    addi s0, zero, 0
    addi s1, zero, 1
    addi s2, zero, 2
    addi s3, zero, 3

# ----------------------------------------------------------------------------------------
# Forwarding from previous ALU instruction to input Op1 of ALU
# ----------------------------------------------------------------------------------------
    addi t1, s0, 1      # t1 = s0 + 1
    add  t2, t1, s2     # t2 = t1 + s2, forward result from t1
    add  zero, zero, zero
    add  zero, zero, zero
    add  zero, zero, zero

# ----------------------------------------------------------------------------------------
# Load-use hazard: 1-cycle stall
# ----------------------------------------------------------------------------------------
    lw   t3, 4(a0)      # Load storage[1] into t3
    add  t4, zero, t3   # t4 = t3 (storage[1] = 10)
    add  zero, zero, zero
    add  zero, zero, zero
    add  zero, zero, zero

# ----------------------------------------------------------------------------------------
# Pipe flush following a jump
# ----------------------------------------------------------------------------------------
    j    next           # Jump to "next"
    add  t5, s1, s2     # These instructions are flushed
    add  t6, s1, s2
next:
    add  zero, zero, zero
    add  zero, zero, zero
    add  zero, zero, zero

# ----------------------------------------------------------------------------------------
# Branch NOT taken
# ----------------------------------------------------------------------------------------
    beq  s1, s2, next   # Branch not taken
    add  t5, s1, s2     # Executes
    add  t6, s1, s3     # Executes

# ----------------------------------------------------------------------------------------
# Branch IS taken
# ----------------------------------------------------------------------------------------
    beq  s1, s1, taken  # Branch is taken
    add  t0, zero, s3   # Flushed
    add  t1, zero, s2   # Flushed
taken:
    add  zero, zero, zero
    add  zero, zero, zero
    add  zero, zero, zero

# ----------------------------------------------------------------------------------------
# Example passing result to 2nd following instruction
# ----------------------------------------------------------------------------------------
    add t0, s1, s2      # t0 = s1 + s2
    nop
    sub t1, t0, s3      # t1 = t0 - s3
    add  zero, zero, zero
    add  zero, zero, zero
    add  zero, zero, zero

# ----------------------------------------------------------------------------------------
# Double hazard example
# ----------------------------------------------------------------------------------------
    add t2, s1, s2      # First write to t2
    sub t2, s2, s3      # Second write to t2
    add t3, t2, s0      # t3 gets the latest t2 value
    add  zero, zero, zero
    add  zero, zero, zero
    add  zero, zero, zero

# ----------------------------------------------------------------------------------------
# Load stalling for branch NOT taken
# ----------------------------------------------------------------------------------------
    lw t4, 8(a0)        # Load storage[2] into t4
    beq t4, s1, skip    # Branch not taken
    add t5, s1, s2      # Executes normally
skip:
    add  zero, zero, zero
    add  zero, zero, zero
    add  zero, zero, zero

# ----------------------------------------------------------------------------------------
# Branch taken to immediate label
# ----------------------------------------------------------------------------------------
    beq s1, s1, here    # Branch always taken
    nop                 # Skipped
here:
    add t6, s1, s2      # Execution continues here
    add  zero, zero, zero
    add  zero, zero, zero
    add  zero, zero, zero

exit:  
    addi a7, zero, 10
    ecall

# ----------------------------------------------------------------------------------------
# An example where an instruction passes its result to the 2nd following instruction
# There should be no stalls
    add  t1, s0, s1   # t1 = 1
    addi t2, s0, s2   # t2 = 2
    add  t3, t1, s3   # t3 = 4
# ----------------------------------------------------------------------------------------
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# An example with a double hazard and check that it works corretly.
# A double hazzard is when the source register of an instruction matches the destination
#  registers of both of the two instructions preceeding it. It should get the newest value.
# There should be no stalls
    add  t1, s0, s1   # t1 = 1
    addi t1, s0, s2   # t1 = 2
    add  t3, t1, s3   # t3 = 5
# ----------------------------------------------------------------------------------------
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# An example with a load stalling for 1 cycle to pass a value to a NOT-TAKEN branch 
#  Is this a data hazard or a control hazard?
    lw   t3, 4(a0)
    beq  t3, zero, exit   # Dependence on t3 is a data hazard.
                          # The branch itself **can be** a control hazard, it taken
# ----------------------------------------------------------------------------------------
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# An example with taken branch to a label which is immediately following the branch
    beq  zero, s0, nextInstr
nextInstr:
    add  t0, s1, s2 # How far does this make it to the pipeline? Is is fetched twice?
    add  t1, s2, s3 # How about this one?
# ----------------------------------------------------------------------------------------



exit:  
    addi      a7, zero, 10    
    ecall

