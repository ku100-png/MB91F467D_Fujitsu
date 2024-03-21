# THIS SAMPLE CODE IS PROVIDED AS IS AND IS SUBJECT TO ALTERATIONS. FUJITSU */
# MICROELECTRONICS ACCEPTS NO RESPONSIBILITY OR LIABILITY FOR ANY ERRORS OR */
# ELIGIBILITY FOR ANY PURPOSES.                                             */
#                 (C) Fujitsu Microelectronics Europe GmbH                  */

# Environment and memory manioulation after program upload


# Settings
SET VARIABLE abortIRQ0 = 1
SET VARIABLE intVectorMonitorDebugger = 10FFC00




# Disable all Interrupts
SET REGISTER I = 0

# Set Table Base Register
SET REGISTER TBR = intVectorMonitorDebugger

# Run to smd_tbr and save TBR of Application
go ,Start91460\smd_tbr
SET VARIABLE intVectorApllication  = %r0

# Copy required vector table entries of monitor debugger in vector table of application
MOVE intVectorMonitorDebugger + 3C0..intVectorMonitorDebugger + 3FF, intVectorApllication + 3C0
    
# Prepare Entries for INT0
IF %abortIRQ0 == 1
  MOVE intVectorMonitorDebugger + 3C0..intVectorMonitorDebugger + 3C3, intVectorApllication + 3BC
  SET MEMORY/BYTE 32 = 3
  SET MEMORY/BYTE 30 = 0
  SET MEMORY/BYTE 31 = 1
  SET MEMORY/BYTE 440 = 10
  SET REGISTER ILM = 1E
ENDIF

# Setting indicates software reset, which leads to that the clock settings are not changed.
SET REGISTER R4 = 8


# Set TBR to Vector table of application
SET REGISTER TBR = intVectorApllication 


# Run to smd_c and let the CS enabled
go ,Start91460\smd_cs
set register r2 = %r2|3

# Run to main()
go ,main
