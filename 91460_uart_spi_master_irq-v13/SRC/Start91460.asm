/* THIS SAMPLE CODE IS PROVIDED AS IS AND IS SUBJECT TO ALTERATIONS. FUJITSU */
/* MICROELECTRONICS ACCEPTS NO RESPONSIBILITY OR LIABILITY FOR ANY ERRORS OR */
/* ELIGIBILITY FOR ANY PURPOSES.                                             */
/*                 (C) Fujitsu Microelectronics Europe GmbH                  */
;==============================================================================
; 1  Contents
;==============================================================================
; 1       Contents
; 2       Disclaimer
;
; 3       History
;
; 4       Settings
; 4.1     Controller Device
; 4.2     Boot / Flash Security 
; 4.3     Stack Type and Stack Size
; 4.4     C++ start-up 
; 4.5     Low-Level Library Interface
; 4.6     Clock Selection
; 4.6.1   Select clock source  
; 4.6.2   Select PLL ratio  
; 4.6.3   Select CPU and peripheral and external-bus clock divider  
; 4.6.4   Select CAN clock 
; 4.6.5   Select Clock Modulator 
; 4.6.6   Set CSV    
; 4.7     Memory Controller
; 4.7.1   FLASH Cache Control Register (FCHCR)
; 4.7.2   FLASH Access Read Timing Settings 
; 4.8     Enable/Disable I-CACHE
; 4.9     External Bus Interface
; 4.9.1   Select Chipselect
; 4.9.2   Set memory addressing for Chipselects
; 4.9.3   Configure Chipselect Area
; 4.9.4   Set Wait cycles for Chipselects
; 4.9.5   Conigure Chipselects CS6/7 for SDRAM memory only
; 4.9.6   Terminal and Timing Control Register
; 4.9.7   Referesh Control Register RCR (for SDRAM)
; 4.9.8   Enable CACHE for chipselect
; 4.9.9   Select External bus mode (Data lines)
; 4.9.10  Select External bus mode (Address lines)
; 4.9.11  Select External bus mode (Control signals)
;
; 5       Section and Data Declaration
; 5.1     Define Stack Size
; 5.2     Define Sections
;
; 6.      S T A R T 
; 6.1     Initialise Stack Pointer and Table Base Register
; 6.2     Set Memory Controller
; 6.3     Check for CSV reset and set CSV
; 6.4     Check reset cause (Operation Reset)
; 6.5     Clock startup
; 6.5.1   Power on Clock Modulator - Clock Modulator Part I
; 6.5.2   Start PLLs 
; 6.5.3   Wait for PLL oscillation stabilisation
; 6.5.4   Set CLKR Register w/o Clock Mode
; 6.5.5   Set Clocks 
; 6.5.5.1 Set CPU and Peripheral and External Bus Clock Divider
; 6.5.5.2 Set External Bus Interface Clock
; 6.5.5.3 Set CAN Clock Prescaler
; 6.5.5.4 Switch Main Clock Mode
; 6.5.5.5 Switch Subclock Mode
; 6.5.5.6 Switch to PLL Mode
; 6.5.6   Enable Frequncy Modulation - Clock Modulator Part II
; 6.6     Set BusInterface
; 6.6.1   Disable all CS
; 6.6.2   Clear TCR Register
; 6.6.3   Set CS0 
; 6.6.4   Set CS1 
; 6.6.5   Set CS2  
; 6.6.6   Set CS3
; 6.6.7   Set CS4
; 6.6.8   Set CS5 
; 6.6.9   Set CS6
; 6.6.10  Set CS7  
; 6.6.11  Set Special SDRAM Config Register  
; 6.6.12  set Port Function Register
; 6.6.13  Set TCR Register
; 6.6.14  Enable CACHE for Selected CS
; 6.6.15  Set SDRAM Referesh Control Register
; 6.6.16  Enable used CS
; 6.7     I-cache on/off

; 6.8     Clear data 
; 6.9     Copy Init Section from ROM to RAM
; 6.10    C Library Initialization
; 6.11    Call C++ Constructors
; 6.12    Call Main Routine
; 6.13    Return from Main Function
;=============================================================================
; 2  Disclaimer
;==============================================================================
;                    Fujitsu Microelectronics Europe GmbH                       
;                http://emea.fujitsu.com/microelectronics 
;                                                              
;    The following  software  is for  demonstration  purposes only.  It is not
;    fully  tested, nor validated  in order  to fullfill  its task  under  all
;    circumstances.  Therefore,  this software or  any part of it must only be
;    used in an evaluation laboratory environment.                        
;    This software is subject to the rules of our standard DISCLAIMER, that is
;    delivered with our  SW-tools on the Fujitsu Microcontrollers CD 
;    (V3.4 or higher "\START.HTM") or on our Internet Pages:                                   
;    http://www.fme.gsdc.de/gsdc.htm
;    http://emea.fujitsu.com/microelectronics 
;
;==============================================================================
; 3  History
;==============================================================================
;
;==============================================================================
;       MB914xx (FR60 CORE ONLY) Series C Compiler's 
;
;       Startup file for memory and basic controller initialisation
;==============================================================================
;History:
;
; 2005-04-18 V1.0 UMa  Release first version
; 2005-06-17 V1.1 UMa  Added bus interface, modified c++ startup
; 2005-06-28 V1.2 UMa  minor changes
; 2005-07-27 V1.3 UMa  default values changed
; 2005-10-04 V1.4 UMa  changed code 'Call main Routine'
;                      Added secutiy section for MB91F467D  
;                      Added Flash Access Read Timing setting section;
; 2005-10-04 V1.5 UMa  Added Flash Controller Section
; 2005-10-28 V1.6 UMa  Check for CSV reset
; 2005-11.16 V1.7 UMa  Monitor Debugger support added: Copy of intvect Table
;                      Ext. Int 0 as abort function
;                      Changed PLL-Startup, Reset HWWD added
; 2005-11-16 V1.7 UMa  Examples for MUL_G changed
; 2006-02-14 V1.8 UMa  mb91464a added
;                      Settings for Clock Spervisor added
;                      Name of Section SECURITY changed to SECURITY_VECTORS
;                      Example values for gear-up changed
; 2006-03-17 V1.9 UMa  Changed Startup for Monitor Debugger
;
;==============================================================================
; 4  Settings
;==============================================================================
;
; CHECK ALL OPTIONS WHETHER THEY FIT TO THE APPLICATION;
;
; Configure this startup file in the "Settings" section. Search for
; comments with leading "; <<<". This points to the items to be set.
;==============================================================================
;
;
#set    OFF             0
#set    ON              1
#set    LOW_PRIOR       31
;
;==============================================================================
; 4.1  Controller Device
;==============================================================================
#set    MB91V460A       0                       ; FR-65, MB91460 series
#set    MB91464A        1                       ; FR-65, MB91460 series
#set    MB91467D        2                       ; FR-65, MB91460 series
;
#set    DEVICE          MB91467D                ; <<< select device
;==============================================================================
; 4.2  Boot / Flash Security 
;==============================================================================
#set    BOOT_FLASH_SEC  OFF                     ; <<< BOOT and Flash Security 
;                                               ;     Vector
; The flash devices have two boot and two boot security vectors. It is 
; important to set the four vectors correctly. Otherwise it might be possible, 
; that the flash device is not accessable any more via the bootrom. 
; Please read carefully the hardware manual.
; 
; OFF:  The security feature is switch off. The section SECURITY_VECTORS is 
;       reserved and the vectors are set.
; ON:   IMPORTANT! The security vectors are not set. But thhe section 
;       SECURITY_VECTORS is reserved.  
;==============================================================================
; 4.3  Stack Type and Stack Size
;==============================================================================

#set    USRSTACK        0                       ; user stack: for main program
#set    SYSSTACK        1                       ; system stack: for main 
                                                ; program and interrupts

#set    STACKUSE        SYSSTACK                ; <<< set active stack

#set    STACK_RESERVE   ON                      ; <<< reserve stack area in 
                                                ;     this module
#set    STACK_SYS_SIZE  0x400-4                 ; <<< byte size of System stack
#set    STACK_USR_SIZE  2                       ; <<< byte size of User stack 

; - If the active stack is set to SYSSTACK, it is used for main program and 
;   interrupts. In this case, the user stack could be set to a dummy size.
;   If the active stack is set to user stack, it is used for the main program 
;   but the system stack s automatically activated, if an interrupt is 
;   serviced. Both stack areas must have a reasonable size.
; - If STACK_RESERVE is ON, the sections USTACK and SSTACK are reserved in this 
;   module. Otherwise, they have to be reserved in other modules. If 
;   STACK_RESERVE is OFF, the size definitions STACK_SYS_SIZE and 
;   STACK_USR_SIZE have no meaning.
; - Even if they are reverved in other modules, they are still initialised
;   in this start-up file.
;
; - If only system stack is used and SSB is linked to a different bank than USB, 
;   make sure that all C-modules (which generate far pointers to stack data) 
;   have "#pragma SSB". Applies only to exclusive configurations.
; - Note, several library functions require quite a big stack (due to ANSI). 
;   Check the stack information files (*.stk) in the LIB\911 directory.
;==============================================================================
; 4.4  Low-Level Library Interface
;==============================================================================
#set    CLIBINIT        OFF                     ; <<< select ext. libray usage

; This option has only to be set, if stream-IO/standard-IO function of
; the C-libraray have to be used (printf(), fopen()...). This also 
; requires low-level functions to be defined by the application 
; software.
; For other library functions like (e.g. sprintf()) all this is not
; necessary. However, several functions consume a large amount of stack.
;==============================================================================
; 4.5  C++ start-up 
;==============================================================================
#set    CPLUSPLUS       OFF                     ; <<< activate if c++ files are 
                                                ;     used

; In the C++ specifications, when external or static objects are used, 
; a constructor must be called followed by the main function.  
; Because four-byte pointers to the main function are stored in the 
; EXT_CTOR_DTOR section, call a constructor sequentially from the 
; lower address of the four addresses in that section.
;
; If using C++ sources, activate this function to create the section
; EXT_CTOR_DTOR. 
;==============================================================================
; 4.6  Clock Selection
;==============================================================================
; There exist 3 internal clock trees.
; CPU clock, peripheral clock and external bus clock
; There is also the possibiliy to select a specific clock for the CAN Controler
; At first step the internal frequency (PLL, use or not) must be selected
; Afterwards the 3 clock trees and the CAN Controler must be set-up.
; There is also a clock modulator, intended to minimize the electromagnetic 
; interference - EMI.
;==============================================================================
; 4.6.1 Select clock source  
;==============================================================================
#set    NOCLOCK         0                       ; do not touch CKSCR register
#set    MAINCLOCK       1                       ; select main clock 
                                                ; (1/2 external)
#set    MAINPLLCLOCK    2                       ; select main clock with PLL
#set    SUBCLOCK        3                       ; select subclock
;
#set    CLOCKSOURCE     MAINPLLCLOCK            ; <<< set clock source
;
#set    ENABLE_SUBCLOCK OFF                     ; <<< set if Subclock exists 
;                                               ;     and should be enabled
;==============================================================================
; 4.6.2 Select PLL ratio  
;==============================================================================
; Select the PLL multiplier. 
; For the maximum permitted frequency, please refer to the hardware manual.
; Values of Hardware Manual (DIV_M and DIV_N): 
;
#set    PLLx2           0x1301                   ; x2  ext. clock/quartz; only MB91V460A
#set    PLLx3           0x0B02                   ; x3  ext. clock/quartz
#set    PLLx4           0x0903                   ; x4  ext. clock/quartz
#set    PLLx5           0x0704                   ; x5  ext. clock/quartz
#set    PLLx6           0x0505                   ; x6  ext. clock/quartz
#set    PLLx7           0x0306                   ; x7  ext. clock/quartz
#set    PLLx8           0x0307                   ; x8  ext. clock/quartz
#set    PLLx9           0x0308                   ; x9  ext. clock/quartz
#set    PLLx10          0x0309                   ; x10 ext. clock/quartz
#set    PLLx12          0x010B                   ; x12 ext. clock/quartz
#set    PLLx14          0x010D                   ; x14 ext. clock/quartz
#set    PLLx15          0x010E                   ; x15 ext. clock/quartz
#set    PLLx16          0x010F                   ; x16 ext. clock/quartz
#set    PLLx18          0x0111                   ; x18 ext. clock/quartz
#set    PLLx20          0x0113                   ; x20 ext. clock/quartz
;
#set    PLLSPEED        PLLx16                    ; <<< set PLL ratio (base cl.)
;
;
;Auto Gear-Up and -Down: The 91460 series offers an auto gear-up and -down for the PLL
;                        Please refer to the hardware manual.
;                        0x00 disables the gear-up gear-down feature
;
; Below examples for the DIV_G and MUL_G (in combination with the values of DIV_M
; and DIV_N of the table above). Please refere to the hardware manual for 
; adequate values for your apllication. The values below are only values of
; orientation, adequate values must be find depending on the application.
;
;       PLL_Multipler        DIV_G          MUL_G      Remarks
;         PLLx2              0x00 (off)       -        PLLx2 only MB91V460A
;         PLLx3              0x00 (off)       -   
;         PLLx4              0x00 (off)       -   
;         PLLx5              0x00 (off)       -   
;         PLLx6              0x00 (off)       -   
;         PLLx7              0x0B            0x1F    
;         PLLx8              0x0B            0x1F   
;         PLLx9              0x0B            0x1F
;         PLLx10             0x0B            0x1F
;         PLLx12             0x0B            0x17
;         PLLx14             0x0B            0x17
;         PLLx15             0x0B            0x17
;         PLLx16             0x0B            0x17
;         PLLx18             0x0B            0x1F
;         PLLx20             0x0B            0x1F
;
;
#set    DIV_G           0x0B                    ; <<< please ref. to HWM
;
#set    MUL_G           0x17                    ; <<< please ref. to HWM
;
;==============================================================================
; 4.6.3 Select CPU and peripheral and External-bus clock  
;==============================================================================
; Select the divide ratio for the clocks used for internal device operation. 
; Do not set a divide ratio that exceeds the maximum operating frequency of 
; the device. For the maximum permitted frequency, please refer to the hardware 
; manual.
;                    
#set    BASECLOCK_DIV1  0x00  ; clock = 1/1 source clock
#set    BASECLOCK_DIV2  0x01  ; clock = 1/2 source clock 
#set    BASECLOCK_DIV3  0x02  ; clock = 1/3 source clock 
#set    BASECLOCK_DIV4  0x03  ; clock = 1/4 source clock 
#set    BASECLOCK_DIV5  0x04  ; clock = 1/5 source clock 
#set    BASECLOCK_DIV6  0x05  ; clock = 1/6 source clock 
#set    BASECLOCK_DIV7  0x06  ; clock = 1/7 source clock 
#set    BASECLOCK_DIV8  0x07  ; clock = 1/8 source clock 
#set    BASECLOCK_DIV9  0x08  ; clock = 1/9 source clock 
#set    BASECLOCK_DIV10 0x09  ; clock = 1/10 source clock 
#set    BASECLOCK_DIV11 0x0A  ; clock = 1/11 source clock 
#set    BASECLOCK_DIV12 0x0B  ; clock = 1/12 source clock 
#set    BASECLOCK_DIV13 0x0C  ; clock = 1/13 source clock 
#set    BASECLOCK_DIV14 0x0D  ; clock = 1/14 source clock 
#set    BASECLOCK_DIV15 0x0E  ; clock = 1/15 source clock 
#set    BASECLOCK_DIV16 0x0F  ; clock = 1/16 source clock 
;
;
#set    CPUCLOCK        BASECLOCK_DIV1          ; <<< set CPU clock divider            
;
#set    PERCLOCK        BASECLOCK_DIV4          ; <<< set peripheral clock div.
;
#set    EXTBUSCLOCK     BASECLOCK_DIV2          ; <<< set Ext. bus clock div.
;
;==============================================================================
; 4.6.4 Select CAN clock 
;==============================================================================
; Select the CAN prescaler clock source and source clock divider
; Do not set a frequency that exceeds the maximum operating frequency of the 
; device. For the maximum permitted frequency, please refer to the hardware 
; manual.
;
#set    PSCLOCK_CLKB    0x00                    ; select core clock (initial)
#set    PSCLOCK_PLL     0x10                    ; select PLL output
#set    PSCLOCK_MAIN    0x30                    ; select Main Oscillation
;
#set    PSCLOCKSOURCE   PSCLOCK_CLKB            ; <<< set CAN Prescaler clock 
;                                               ;     source
;
#set    PSDVC           BASECLOCK_DIV4         ; <<< set prescaler CAN clock 
;                                               ;     divider 
;
;
;
; Enable CAN clocks. The CAN clock for every required CAN have to be enabled.
; 0 - CAN clock is enabled
; 1 - CAN clock is disabled
; 
#set    CANCLOCK        B'00000000              ; <<< Enable CAN Clocks 
;                         ||||||||
;                         ||||||||__ CAN 0
;                         |||||||___ CAN 1
;                         ||||||____ CAN 2
;                         |||||_____ CAN 3
;                         ||||______ CAN 4
;                         |||_______ CAN 5
;                         ||________ reserved (allways '0')
;                         |_________ reserved (allways '0')
;
;
;==============================================================================
; 4.6.5 Select Clock Modulator  
;==============================================================================
; Enable(1) or disable(0) clock modulator
; Please refer to the hardware manual if you enable clock modulation.
; The register CMPR with the modulation degree is set, dependant on the 
; PLL-Clock.
;
#set    CLOMO           OFF                        ; <<< set clock modulator      
;
#set    CMPR            0x05F2                     ; <<< Please ref. to the HWM
;
;==============================================================================
; 4.6.6 Set CSV 
;==============================================================================
; Select the settings for the CSV
;
;
#set    CSV          B'00011100                    ; <<< set CSV 
;                      ||||||||
;                      ||||||||__ OUTE
;                      |||||||___ SRST
;                      ||||||____ SSVE
;                      |||||_____ MSVE
;                      ||||______ RCE
;                      |||_______ SM (read only)
;                      ||________ MM (read only)
;                      |_________ SCKS
;
; BIT[7]: SCKS - Sub clock select (only used for single clock devices)
;         0 - Real single clock device (default)
;         1 - Dual clock device 
;
; BIT[6]: MM - Main clock missing
;         0 - Missing main clock has not been detected (default)
;         1 - Missing main clock has been detected
;
; BIT[5]: SM - Sub clock missing
;         0 - Missing sub-clock has not been detected (default)
;         1 - Missing sub-clock has been detected
;
; BIT[4]: RCE 
;         0 - disable
;         1 - enable (default)
;
;
; BIT[3]: MSVE - Read only
;
;
; BIT[2]: SSVE - Read only
;
;
;
; BIT[1]: SRST - Sub-clock mode reset
;         0 - do not perform reset upon transition from main clock to
;             sub-clock modes if sub-clock is already missing (default)
;         1 - perform reset upon transition from main clock to subclock
;             modes if sub-clock is already missing
;
; BIT[0]: OUTE - Output enable
;         0 - Do not enable ports for MM and SM output (default)
;         1 - Enable ports for MM and SM output
;
;==============================================================================
; 4.7     Memory Controller
;==============================================================================
;==============================================================================
; 4.7.1   FLASH Cache Control Register (FCHCR)
;==============================================================================
; BIT[9]: REN - Non-cacheable area Range Enable
;         0 - FCHA1 defines address mask (default)
;         1 - FCHA1 defines second point for the non-cacheable address range 
;             from FCHA0 to FCHA1
;
; BIT[8]: TAGE - TAG RAM access Enable
;         0 - Memory mapped TAG RAM access disabled (default)
;         1 - Memory mapped TAG RAM access enabled
;
; BIT[7]: FLUSH - Flush instruction cache entries
;         0 - Flushing the instruction cache entries has been completed
;         1 - Actually flushing the instruction cache entries
;
; BIT[6]: DBEN - Data Buffer ENable
;         0 - Buffering of read data is disabled (default)
;         1 - Buffering of read data is enabled
;
; BIT[5]: PFEN - PreFetch ENable
;         0 - Prefetch of instructions is disabled (default)
;         1 - Prefetch of instructions is enabled
;
; BIT[4]: PFMC - Prefetch Miss Cache enable
;         0 Standard cache algorithm (default)
;         1 Prefetch misses are cached only
;
; BIT[3]: LOCK - Global lock of cache entries
;         0 - Write of cache entries enabled (default)
;         1 - Writing of cache entries is disabled, the cache contents is 
;             locked
;
; BIT[2]: ENAB - Instruction cache enable
;         0 - The instruction cache is disabled (default)
;         1 - Enable the instruction cache
;
; BIT[1:0]: SZ[1:0] - Cache size configuration (only valid for MB91V460)
;        00 - 0kByte - Cache disabled
;        01 - 4kByte (1024 entries)
;        10 - 8kByte (2048 entries)
;        11 - 16kByte (4096 entries) (default)
;
#set    FLASHCONTROL    B'0000100110         ; <<< Set Flash Control      
;                         ||||||||||
;                         ||||||||||__ SZ0  bit
;                         |||||||||___ SZ1  bit
;                         ||||||||____ ENAB bit
;                         |||||||_____ LOCK bit
;                         ||||||______ PFMC bit
;                         |||||_______ PFEN bit
;                         ||||________ DBEN bit
;                         |||_________ FLUSH bit
;                         ||__________ TAGE bit
;                         |___________ REN bit
;                        

;==============================================================================
; 4.7.2   FLASH Access Read Timing Settings 
;==============================================================================
; Depending on the frequency of the core clock different minimum waitstates are
; required for the embedded flash. Recommended values are (These settings are 
; for FLASH memory synchronous read mode (FMCS.ASYNC=0).:
; 
;        Core clock CLKB            |   ATD/ALEH  | EQ  | WTC   
;-------------------------------------------------------------
;             2 MHz                 |      0      |  0  |  1
;         32 MHz, 46 MHz            |      0      |  1  |  2
; 64 MHz, 80 Mhz, 96 MHz, 100 MHz   |      1      |  3  |  4
;
; The ALEH setting is the same as the ATD setting therefore it will be updated 
; automatically when applying a new setting value to the FMWT.ATD[2:0] register.
;
; WTP[1:0] - Wait cycles for FLASH in page access
; 
; WEXH[1:0] - Minimum WEX High timing requirement
;
; WTC[3:0] - Wait cycles for FLASH memory access
;
; FRAM - Wait cycles for F-Bus general purpose RAM memory access
;
; ATD[2:0] - Duration of the ATDIN signal for FLASH memory access
;
; EQ[3:0] - Duration of the EQIN signal for FLASH memory access
;
;
#set    FLASHREADT      B'1101010010010011         ; <<< Set Flash Read Timing      
;                         ||||||||||||||||
;                         ||||||||||||||||__ EQ0  bit
;                         |||||||||||||||___ EQ1  bit
;                         ||||||||||||||____ EQ2  bit
;                         |||||||||||||_____ EQ3  bit
;                         ||||||||||||______ ATD0 bit
;                         |||||||||||_______ ATD1 bit
;                         ||||||||||________ ATD2 bit
;                         |||||||||_________ FRAM bit
;                         ||||||||__________ WTC0 bit
;                         |||||||___________ WTC1 bit
;                         ||||||____________ WTC2 bit
;                         |||||_____________ WTC3 bit
;                         ||||______________ WEXH0 bit
;                         |||_______________ WEXH1 bit
;                         ||________________ WTP0 bit
;                         |_________________ WTP1 bit
;
;
;==============================================================================
; 4.8  Enable/Disable I-CACHE
;==============================================================================
#set    C1024           1                       ; CACHE Size: 1024 BYTE
#set    C2048           2                       ; CACHE Size: 2048 BYTE
#set    C4096           3                       ; CACHE Size: 4096 BYTE

#set    CACHE           OFF                     ; <<< Select use of CACHE 
#set    CACHE_SIZE      C4096                   ; <<< select size of CACHE 

; It is possible to use the CACHE functionality on the I-Bus.
; Check the corresponidng Hardware Manual of the series.
; This is general CACHE enable, select in external BusInterface set-up,
; which Chipselect (CSx) area should used with CACHE
; The MB91467D and MB91464A does not support this feature.
;
;==============================================================================
; 4.9  External Bus Interface
;==============================================================================
; Following set-up the Bus-Interface
; When using SDRAM or FCRAM CS6 and CS7 must be used
; All chipselects can be used with 'normal' Memory 
; Be aware of different wait register meaning when using SDRAM at CS6 and/or 7
; The MB91464A does not offer an external businterface
;
#set    EXTBUS          ON                         ; <<< Enable Extern Bus-Int.
;
;==============================================================================
; 4.9.1  Select Chipselect
;==============================================================================
; Note: If the SWB Monitor Debugger is used, set the CS1 (external RAM only)
; or CS0 and CS 1 (external RAM and flash) to off.
; Note: The settings of the external bus interface applies for the SK-01460-Main
;
#set    CS0             OFF                        ; <<< select CS (ON/OFF)
#set    CS1             OFF                        ; <<< select CS (ON/OFF)
#set    CS2             OFF                        ; <<< select CS (ON/OFF)
#set    CS3             OFF                        ; <<< select CS (ON/OFF)
#set    CS4             OFF                        ; <<< select CS (ON/OFF)
#set    CS5             OFF                        ; <<< select CS (ON/OFF)
#set    CS6             OFF                        ; <<< select CS (ON/OFF)
#set    CS7             OFF                        ; <<< select CS (ON/OFF)
#set    SDRAM           OFF                        ; <<< select if SDRAM is 
;                                                  ;     connected to CS6/7

; Select used Chipselects.
; NOTE: Check Hardware Manual which Chipselect signals are available 
; for the used series!
; 1: enabled
; 0: disabled

#set    ENACSX          B'00000000                 ; <<< enable Chipselects
;                         ||||||||
;                         ||||||||__ CS0 bit, enable/disable CS0 (1/0)
;                         |||||||___ CS1 bit, enable/disable CS1 (1/0)
;                         ||||||____ CS2 bit, enable/disable CS2 (1/0)
;                         |||||_____ CS3 bit, enable/disable CS3 (1/0)
;                         ||||______ CS4 bit, enable/disable CS4 (1/0)
;                         |||_______ CS5 bit, enable/disable CS5 (1/0) 
;                         ||________ CS6 bit, enable/disable CS6 (1/0)
;                         |_________ CS7 bit, enable/disable CS7 (1/0)
;==============================================================================
; 4.9.2  Set memory addressing for Chipselects
;==============================================================================
#set    AREASEL0        0x0020                     ; <<< set start add. for CS0  
#set    AREASEL1        0x0080                     ; <<< set start add. for CS1          
#set    AREASEL2        0x0000                     ; <<< set start add. for CS2
#set    AREASEL3        0x0000                     ; <<< set start add. for CS3
#set    AREASEL4        0x0000                     ; <<< set start add. for CS4
#set    AREASEL5        0x0000                     ; <<< set start add. for CS5
#set    AREASEL6        0x3000                     ; <<< set start add. for CS6
#set    AREASEL7        0x0000                     ; <<< set start add. for CS7

; set starting address of each used Chipselect. Chipselects not used
; (not set to ON in 4.7.2) must no set (setting ignored).
; NOTE: Just the upper 16-bit must be used A[32-16]
; e.g. When using start address 0x00080000 set 0x0008
;==============================================================================
; 4.9.3  Configure Chipselect Area
;==============================================================================
; Bit description:
; Configure the used Chipselect ACRx register
;
; TYP3 TYP2 TYP1 TYP0    Select access type of each CS
; 0    0    X    X     : Normal access (asynchronous SRAM, I/O, 
;                        single/page/busrt-ROM/FLASH) 
; 0    1    X    X     : Address/data multiplexed (8bit / 16bit bus width only)
; 0    X    X    0     : WAIT insertion by RDY disabled
; 0    X    X    1     : WAIT insertion by RDY enabled
; 0    X    0    X     : The WR0X pin to the WR3X pin are used as write strobes 
;                        (WRX is fixed at H-Level)
; 0    X    1    X     : The WRX pin is used as write strobe 
; 1    0    0    0     : Memory type A: SDRAM/FCRAM (Auto pre-charge used)  
; 1    0    0    1     : Memory type B: FCRAM (Auto pre-charge used)  
; 1    0    1    0     : setting not allowed
; 1    0    1    1     : setting not allowed
; 1    1    0    0     : setting not allowed
; 1    1    0    1     : setting not allowed
; 1    1    1    0     : setting not allowed
; 1    1    1    1     : mask area setting
;
; LEND: select BYTE ordering 
; 0: Big endian,  1: Little endian
;
; WREN: enable or disable write access 
; 1: enabled, 0: disabled     
;
; PFEN: Enable or disable the pre-fetch
; 1: enabled, 0: disabled
;
; SREN: Enable or disable the sharing of BRQ and BGRNTX 
; 1: enabled (CSx pin High-Z), 0: disabled 
;
; BST1  BST0  : set burst size of chip select area
; 0     0     : 1 burst (single access)
; 0     1     : 2 bursts (Address boundary 1 bit) 
; 1     0     : 4 bursts (Address boundary 2 bit)
; 1     1     : 8 bursts (Address boundary 3 bit)
;
; DBW1  DBW0  : Set data bus width
; 0     0     : 8-bit (BYTE access) 
; 0     1     : 16-bit (HALF-WORD access) 
; 1     0     : 32-bit (WORD access) 
; 1     1     : Reserved  
;
; ASZ3 ASZ2 ASZ1 ASZ0  :  Select memory size of each chipselect 
; 0    0    0    0     : 64 Kbyte  (0x01.0000 bytes; use ASR A[31:16] bits) 
; 0    0    0    1     : 128 Kbyte (0x02.0000 bytes; use ASR A[31:17] bits)
; 0    0    1    0     : 256 Kbyte (0x04.0000 bytes; use ASR A[31:18] bits)
; 0    0    1    1     : 512 Kbyte (0x08.0000 bytes; use ASR A[31:19] bits)
; 0    1    0    0     : 1 Mbyte   (0x10.0000 bytes; use ASR A[31:20] bits)
; 0    1    0    1     : 2 Mbyte   (0x20.0000 bytes; use ASR A[31:21] bits)
; 0    1    1    0     : 4 Mbyte   (0x40.0000 bytes; use ASR A[31:22] bits)
; 0    1    1    1     : 8 Mbyte   (0x80.0000 bytes; use ASR A[31:23] bits)
; 1    0    0    0     : 16 Mbyte  (0x100.0000 bytes; use ASR A[31:24] bits)
; 1    0    0    1     : 32 Mbyte  (0x200.0000 bytes; use ASR A[31:25] bits)
; 1    0    1    0     : 64 Mbyte  (0x400.0000 bytes; use ASR A[31:26] bits)
; 1    0    1    1     : 128 Mbyte (0x800.0000 bytes; use ASR A[31:27] bits)
; 1    1    0    0     : 256 Mbyte (0x1000.0000 bytes; use ASR A[31:28] bits)
; 1    1    0    1     : 512 Mbyte (0x2000.0000 bytes; use ASR A[31:29] bits)
; 1    1    1    0     : 1024 Mbyte(0x4000.0000 bytes; use ASR A[31:30] bits)
; 1    1    1    1     : 2048 Mbyte(0x8000.0000 bytes; use ASR A[31] bit)
;==============================================================================
#set    CONFIGCS0       B'1000100000100010         ; <<< Config. CS0, ACR
#set    CONFIGCS1       B'0110100000100010         ; <<< Config. CS1, ACR 
#set    CONFIGCS2       B'0000000000000000         ; <<< Config. CS2, ACR 
#set    CONFIGCS3       B'0000000000000000         ; <<< Config. CS3, ACR 
#set    CONFIGCS4       B'0000000000000000         ; <<< Config. CS4, ACR  
#set    CONFIGCS5       B'0000000000000000         ; <<< Config. CS5, ACR  
#set    CONFIGCS6       B'0111100001101000         ; <<< Config. CS6, ACR  
#set    CONFIGCS7       B'0000000000000000         ; <<< Config. CS7, ACR  
;                         ||||||||||||||||
;                         ||||||||||||||||__ TYP0 bit, TYP0-4 bits select access type
;                         |||||||||||||||___ TYP1 bit
;                         ||||||||||||||____ TYP2 bit
;                         |||||||||||||_____ TYP3 bit
;                         ||||||||||||______ LEND bit, select little '1' or big endian '0'
;                         |||||||||||_______ WREN bit, en-/disable (1/0) Write access
;                         ||||||||||________ PFEN bit, en-/disable (1/0) pre-fetch
;                         |||||||||_________ SREN bit, en-/disable (1/0) share of BRQ & BGRNTX
;                         ||||||||__________ BST0 bit, BSTx bits select burst size
;                         |||||||___________ BST1 bit
;                         ||||||____________ DBW0 bit, DBWx select data bus width
;                         |||||_____________ DBW1 bit
;                         ||||______________ ASZ0 bit, ASZx bits select address size of CS
;                         |||_______________ ASZ1 bit
;                         ||________________ ASZ2 bit
;                         |_________________ ASZ3 bit


;==============================================================================
; 4.9.4  Set Wait cycles for Chipselects
;==============================================================================
; Bit description:
; set Waitstates for each chipselect area (CSx)
;
; W15  W14  W13  W12  :  First access wait cycle can be set (0-15 cycles)
; 0    0    0    0    :  0 Wait state
; 0    0    0    1    :  1 Auto-wait cycle
; 0    0    1    0    :  2 Auto-wait cycle
; ....
; 1    1    1    1    :  15 Auto wait cycles
;
; W11  W10  W09  W08  :  Intra-page access cycle select (0-15 cycles)
; 0    0    0    0    :  0 Wait state
; 0    0    0    1    :  1 Auto-wait cycle
; 0    0    1    0    :  2 Auto-wait cycle
; ....
; 1    1    1    1    :  15 Auto wait cycles
;
; W07  W06  : Read -> Write idle cycle selection
; 0    0    : 0 cycle
; 0    1    : 1 cycle
; 1    0    : 2 cycles
; 1    1    : 3 cycles
; The read->write cycle is set to prevent a collision between read
; and write data on the data bus when a write cycle follows a read cycle.
;
; W05  W04  : select Write recovery cycle
; 0    0    : 0 cycle
; 0    1    : 1 cycle
; 1    0    : 2 cycles
; 1    1    : 3 cycles
; The write recovery cycle is set when controlling accesses to a device with
; a restriction on the interval between a write access and the next access.
; 
; W03  : WR0X to WR3X/WRX outout timing selection
; 0 : MCLK synchronous write output enable (ASX=L)
; 1 : Asynchronous write strobe output (norma operation)
; The WR0X to WR3X/WRX output timing select whether to use the write strobe 
; output as an asynchronous strobe or as a synchronouos strobe.   
;
; W02  : Address -> CSX Delay selection
; 0  : no delay selected
; 1  : delay selected
; When no delay is selected, CS0X to CS7X start being asserted at same time 
; as ASX is asserted. 
;
; W01  : CSX -> RDX/WRX setup extention cycle
; 0    : 0 cycle
; 1    : 1 cycle
; When 0 (0 cycle) is set, RDX/WR0X to WR3X/WRX is output fastest on the rising 
; edge of the external-memory clock MCLK output established immediately after 
; assertion of CSX. WR0X to WR3X/WRX may be delayed by 1 cycle or more depending 
; on the state of the internal bus. When 1 (1 cycle) is set, output of all of 
; RDX/WR0X to WR3X/WRX is always delayed by 1 cycle or more. 
;  
; W00  : RDY/WRX -> CSX hold extension cycle
; 0    : 0 cycle
; 1    : 1 cycle
; When 0 (0 cycle) is set, CS0X to CS7X are negated after the elapse of the  
; hold delay from the rising edge of the external-memory clock MCLK output  
; established after negation of RDX/WR0X to WR3X/WRX. When 1 (1 cycle) is set, 
; CS0X to CS7X are delayed by 1 cycle while being negated.
;==============================================================================
#set    WAITREG0        B'0011001101111000         ; <<< CS0 Waitstates, AWR  
#set    WAITREG1        B'0011001101111000         ; <<< CS1 Waitstates, AWR  
#set    WAITREG2        B'0000000000000000         ; <<< CS2 Waitstates, AWR 
#set    WAITREG3        B'0000000000000000         ; <<< CS3 Waitstates, AWR 
#set    WAITREG4        B'0000000000000000         ; <<< CS4 Waitstates, AWR 
#set    WAITREG5        B'0000000000000000         ; <<< CS5 Waitstates, AWR 
;                         ||||||||||||||||
;                         ||||||||||||||||__ W00 bit, RDY/WRY-> CSX hold cycle
;                         |||||||||||||||___ W01 bit, CSX -> RDX/WRX setup extension cycle
;                         ||||||||||||||____ W02 bit, Address -> CSX Delay selection
;                         |||||||||||||_____ W03 bit, WR0X to WR3X/WRX outout timing selection
;                         ||||||||||||______ W04 bit, W04/W05 Write recovery cycle
;                         |||||||||||_______ W05 bit, 
;                         ||||||||||________ W06 bit, W06/07 Read -> Write idle cycle 
;                         |||||||||_________ W07 bit, selection
;                         ||||||||__________ W08 bit, W08-W11 Intra-page access cycle 
;                         |||||||___________ W09 bit, select (0-15 cycles)
;                         ||||||____________ W10 bit 
;                         |||||_____________ W11 bit
;                         ||||______________ W12 bit, W12-W15 First access wait cycle  
;                         |||_______________ W13 bit, select   (0-15 cycles)
;                         ||________________ W14 bit
;                         |_________________ W15 bit
;
;==============================================================================
; CHECK Type of connected Memory (If SDRAM/FCRAM used) for CS6 and CS7 <<< 
; NOTE: For CS6 and CS7 there exists a second possible initialisation.
; When using TYP3-0:1000 in ACR6 or ACR7 registerthe wait register must set-up as 
; following:
; 
; W15 : RESERVED, ALWAYS WRITE 0 !
;
; W14  W13  W12  : set RAS-CAS delay (1 - 8 cycles)
; 0    0    0    : 1 cycle
; 0    0    1    : 2 cycle
; ...
; 1    1    1    : 8 cycle
; Set same settings for all areas which SDRAM/FCRAM is conneted.
;
; W11 : RESERVED, ALWAYS WRITE 0 !
;
; W10  W09  W08  : set CAS latency (1 - 8 cycles)
; 0    0    0    : 1 cycle
; 0    0    1    : 2 cycle
; ...
; 1    1    1    : 8 cycle
; Set same settings for all areas which SDRAM/FCRAM is conneted.
;
; W07  W06  :  set Read -> Write idle Cycle (1 - 4 cycles)
; 0    0    :  1 cycle
; 0    1    :  2 cycles
; 1    0    :  3 cycles
; 1    1    :  4 cycles
; Set same settings for all areas which SDRAM/FCRAM is conneted.
;
; W05  W04  :  set Write recovery cycle (1 - 4 cycles)
; 0    0    :  Prohibited
; 0    1    :  2 cycles
; 1    0    :  3 cycles
; 1    1    :  4 cycles
; Set the minimum count of cycles for the period from the last write data
; output to the issuance of the next read command.
; Set same settings for all areas which SDRAM/FCRAM is conneted.
;
; W03 W02   :  RAS active Time
; 0    0    :  1 cycle
; 0    1    :  2 cycles
; 1    0    :  5 cycles
; 1    1    :  6 cycles
; Set the minimum number of cycles for RAS active time.
; Set same settings for all areas which SDRAM/FCRAM is conneted.
;
; W01 W00   :  RAS precharge cycles.
; 0    0    :  1 cycle
; 0    1    :  2 cycles
; 1    0    :  5 cycles
; 1    1    :  6 cycles
; Set to the number of RAS precharge cycles.
; Set same settings for all areas which SDRAM/FCRAM is conneted.
;==============================================================================
#set    WAITREG6        B'0001000101011001         ; <<< configure CS6 Waitstates 
#set    WAITREG7        B'0000000000000000         ; <<< configure CS7 Waitstates
;                         ||||||||||||||||
;                         ||||||||||||||||__ W00 bit W0-W1 RAS precharge cycles
;                         |||||||||||||||___ W01 bit
;                         ||||||||||||||____ W02 bit W2-W3 RAS active Time
;                         |||||||||||||_____ W03 bit
;                         ||||||||||||______ W04 bit W4-W5 Write recovery cycle
;                         |||||||||||_______ W05 bit 
;                         ||||||||||________ W06 bit W6-W7 Read->Write idle cycle
;                         |||||||||_________ W07 bit
;                         ||||||||__________ W08 bit W8-W10 CAS latency 
;                         |||||||___________ W09 bit
;                         ||||||____________ W10 bit 
;                         |||||_____________ W11 bit  reserved
;                         ||||______________ W12 bit  W12-W16 RAS-CAS delay 
;                         |||_______________ W13 bit
;                         ||________________ W14 bit  
;                         |_________________ W15 bit  reserved
;
;==============================================================================
; 4.9.5  Conigure Chipselects CS6/7 for SDRAM memory only
;==============================================================================
; When connecting SDRAM/FCRAM to CS6/7 and TYP3-0=1000 in ACRx register
; a further register must be setup for CS6 and 7 only.
;
; PSZ2  PSZ1  PS0 :  Select page size of connected memory
; 0     0     0   :  8-bit column address = A0 to A7 
; 0     0     1   :  9-bit column address = A0 to A8 
; 0     1     0   :  10-bit column address = A0 to A9 
; 0     1     1   :  11-bit column address = A0 to A9, A11 
; 1     X     X   :  setting disabled
;
; WBST : Write burst enable
; 0: Single Write,  1: Busrt Write
;
; BANK  : Set number of connected SDRAM banks
; 0 : 2 banks, 1 : 4 banks
;
; ABS1  ABS0  :  Set maximum number of bank, active at same time
; 0     0     :  1 bank
; 0     1     :  2 banks
; 1     0     :  3 banks
; 1     1     :  4 banks
;

#set    MEMCON           B'00000111                 ; <<< set special SDRAM register MCRA
;                          ||||||||
;                          ||||||||__ ABS0 bit, set max. active banks (ABS1,0)
;                          |||||||___ ABS1 bit
;                          ||||||____ BANK bit, set number of banks connected to CS
;                          |||||_____ WBST bit, Write burst enable/disable
;                          ||||______ PSZ0 bit, Set page size (PSZ2-0)
;                          |||_______ PSZ1 bit 
;                          ||________ PSZ2 bit
;                          |_________ reserved, always write 0 
;==============================================================================
; 4.9.6  Terminal and Timing Control Register
;==============================================================================
; This register controls the general functions of the external bus 
; interface controller such as the common-pin function setting
; and timing control.
; BREN : BRQ input enable
; 0 : disabled, 
; 1 : enabled, Bus sharing of BRQ/BGRNTX performed
;
; PSUS: prefetch suspension bit 
; 0: Prefetch enabled,  1: Prefetch disabled
;
; PCLR  : Prefetch buffer all clear
; 0 : normal state,  1: Prefetch buffer cleared
;
; When 1 is written to this bit, the prefetch buffer is cleared once. 
; When clearing of the prefetch buffer is completed, the value of this
; bit returns automatically to 0. 
;
; OHT1  OHT0  : Output hold selection bit
; 0     0     : Output performed at falling edge of SYSCLK/MCLK
; 0     1     : Output performed about 3ns after falling edge of SYSCLK/MCLK
; 1     0     : Output performed about 4ns after falling edge of SYSCLK/MCLK
; 1     1     : Output performed about 5ns after falling edge of SYSCLK/MCLK
; The delay value is the target value under typical conditions.
; The falling timing of the asynchronous read/write strobe (RDX, WR0X, WR1X, 
; WR2X, WR3X, WRX, IOWRX,IORDX) and the delayed CSX is not subjected to 
; this delay adjustment.
;
; RDW1  RDW0  : Wait cycle reduction 
; 0     0     : Normal Wait (AWR0 - 7 setting)
; 0     1     : 1/2 of AWR0 - 7 setting value
; 1     0     : 1/4 of AWR0 - 7 setting value
; 1     1     : 1/8 of AWR0 - 7 setting value
; This function is used to prevent an excessive access cycle wait while 
; operating at a low-speed clock (such as while base clock operating at 
; low speed or high frequency division rate for external bus clock).

#set    TIMECONTR         B'00000000                ; <<< set TCR register
;                           ||||||||
;                           ||||||||__ RDW0 bit, set wait cycle reduction (RDW0,1)
;                           |||||||___ RDW1 bit
;                           ||||||____ OHT0 bit, set output hold delay (OHT1,0)
;                           |||||_____ OHT1 bit
;                           ||||______ reserved, always write 0 
;                           |||_______ PCLR bit, prefetch buffer clear 
;                           ||________ PSUS bit, prefetch suspend
;                           |_________ BREN bit, BRQ input enable 
;
;==============================================================================
; 4.9.7  Referesh Control Register RCR (for SDRAM)
;==============================================================================
; This register sets various SDRAM refresh controls. When SDRAM control 
; is not set for any area, the setting of this register is meaningless,
; but do not change the register value at initial state.
; When a read is performed using a read-modify-write instruction,
; 0 always returns from the SELF, RRLD, and PON bits.
;
; SELF  : Self refresh control
; 0 : auto refresh or power down
; 1 : Transitions to self-refresch mode
;
; RRLD : Refresh counter Activation Control
; 0 : Disabled,  1 : Autorefresh performed once, then value of RFINT reloaded
;
; RFINT5 RFINT4 RFINT3 RFINT2 RFINT1 RFINT0 : auto refresh interval
; The auto-refresh interval can be calculated using the following
; expression: {(RFINT [5:0] value)   32   (external-bus clock cycle)}
; when decentralized refresh mode enabled;
; {(RFINT [5:0] value)   32   (the count of times specified using RFC)
;    (external-bus clock cycle)} when centralized refresh mode enabled.
; To stop auto-refresh, write 000000B to the RFINT [5:0] bits.
; The refresh counter also decrements while the auto-refresh command is being 
; issued.
;
; BRST : Burst refresh control
; 0 : Decentralised refresh, 1: burst refresh
; When decentralized refresh is set, the auto-refresh command is issued once for
; each refresh interval. When burst-refresh is set, the auto-refresh command is
; issued successively for the count of times specified by the refresh counter for
; each refresh interval.
;
; RFC2  RFC1  RFC0  : Refresh Count
; 0     0     0     : 256
; 0     0     1     : 512
; 0     1     0     : 1024
; 0     1     1     : 2048
; 1     0     0     : 4096
; 1     0     1     : 8192
; 1     1     0     : Setting disabled
; 1     1     1     : Refresh disabled
; The specified refresh count is the count of centralized refreshes performed
; before and after a transition is made to the self-refresh mode. When burst
; refresh is selected using the BRST bit, the refresh count specified here
; is the count of refresh commands issued for each refresh interval.
; 
; PON  : Power-on control
; 0 : disabled,  1: poweron sequence started
; When 1 is written to the PON bit, the SDRAM power-on sequence is started.
; Be sure to set the corresponding registers such as AWR, MCRA (or MCRB),
; and CSER before starting this power-on sequence. This bit returns to 0
; when the power-on sequence starts. To enable the PON bit, enable the RFINT
; and RRLD settings, to operate the refresh counter as well. The PON bit alone
; does not perform the refresh operation.
; Do not enable the PON bit together with the SELF bit.
; When a read is performed using a read-modify-write instruction, 
; '0' is always returns.
;
; TRC2  TRC1  TRC0  : Refresh Cycle 
; 0     0     0     : 4
; 0     0     1     : 5
; 0     1     0     : 6
; 0     1     1     : 7
; 1     0     0     : 8
; 1     0     1     : 9
; 1     1     0     : 10
; 1     1     1     : 11

#set    REFRESH         B'1110001001000111          ; <<< set Refresh Control Register (SDRAM use) 
;                         ||||||||||||||||
;                         ||||||||||||||||__ TRC0 bit, set refresh cycle (TRC2-0)
;                         |||||||||||||||___ TRC1 bit
;                         ||||||||||||||____ TRC2 bit
;                         |||||||||||||_____ PON bit, set power-on control
;                         ||||||||||||______ RFC0 bit, set refresh count (RFC2-0)
;                         |||||||||||_______ RFC1 bit 
;                         ||||||||||________ RFC2 bit 
;                         |||||||||_________ BRST bit, set burst refresh control 
;                         ||||||||__________ RFINT0 bit, set auto refresh interval
;                         |||||||___________ RFINT1 bit, (RFINT5-0)
;                         ||||||____________ RFINT2 bit
;                         |||||_____________ RFINT3 bit
;                         ||||______________ RFINT4 bit
;                         |||_______________ RFINT5 bit
;                         ||________________ PRLD bit, counter refresh strat control
;                         |_________________ SELF bit, self refresh control
;
; NOTE: PON bit is set after the above setting. Do not set PON bit to 1 in the 
;       above setting. Otherwise the settings are not correct set.
;==============================================================================
; 4.9.8  Enable CACHE for chipselect
;==============================================================================
; Additional to the general CACHE enable setting, select which
; chipselect area is used with Cache functionality
;
#set    CHEENA          B'11111111                  ; <<< enable/disable Cache for each CS
;                         ||||||||
;                         ||||||||__ CHE0 bit, CS0 area
;                         |||||||___ CHE1 bit, CS1 area
;                         ||||||____ CHE2 bit, CS2 area
;                         |||||_____ CHE3 bit, CS3 area
;                         ||||______ CHE4 bit, CS4 area 
;                         |||_______ CHE5 bit, CS5 area 
;                         ||________ CHE6 bit, CS6 area
;                         |_________ CHE7 bit, CS7 area 
;
;==============================================================================
; 4.9.9  Select External bus mode (Data lines)
;==============================================================================
; Select if the following ports are set to
; 1: External bus mode, I/O for data lines or
; 0: General purpose port 
; By default these ports are set to External bus mode
#set    PFUNC0          B'11111111                  ;<<< select data lines or general purpose port
;                         ||||||||
;                         ||||||||__ D24 / P00_0
;                         |||||||___ D25 / P00_1
;                         ||||||____ D26 / P00_2
;                         |||||_____ D27 / P00_3
;                         ||||______ D28 / P00_4
;                         |||_______ D29 / P00_5
;                         ||________ D30 / P00_6
;                         |_________ D31 / P00_7
;
#set    PFUNC1          B'11111111                  ;<<< select data lines or general purpose port
;                         ||||||||
;                         ||||||||__ D16 / P01_0
;                         |||||||___ D17 / P01_1
;                         ||||||____ D18 / P01_2
;                         |||||_____ D19 / P01_3
;                         ||||______ D20 / P01_4
;                         |||_______ D21 / P01_5
;                         ||________ D22 / P01_6
;                         |_________ D23 / P01_7
;
#set    PFUNC2          B'11111111                  ;<<< select data lines or general purpose port
;                         ||||||||
;                         ||||||||__ D8 / P02_0
;                         |||||||___ D9 / P02_1
;                         ||||||____ D10 / P02_2
;                         |||||_____ D11 / P02_3
;                         ||||______ D12 / P02_4
;                         |||_______ D13 / P02_5
;                         ||________ D14 / P02_6
;                         |_________ D15 / P02_7
;
#set    PFUNC3          B'11111111                  ;<<< select data lines or general purpose port
;                         ||||||||
;                         ||||||||__ D0 / P03_0
;                         |||||||___ D1 / P03_1
;                         ||||||____ D2 / P03_2
;                         |||||_____ D3 / P03_3
;                         ||||______ D4 / P03_4
;                         |||_______ D5 / P03_5
;                         ||________ D6 / P03_6
;                         |_________ D7 / P03_7
;
;==============================================================================
; 4.9.10  Select External bus mode (Address lines)
;==============================================================================
; Select if the following ports are set to 
; 1: External bus mode, I/O for address lines or
; 0: General purpose port 
; By default these ports are set to External bus mode
#set    PFUNC4          B'11111111                  ;<<< select address lines or general purpose port
;                         ||||||||
;                         ||||||||__ A24 / P04_0
;                         |||||||___ A25 / P04_1
;                         ||||||____ A26 / P04_2
;                         |||||_____ A27 / P04_3
;                         ||||______ A28 / P04_4
;                         |||_______ A29 / P04_5
;                         ||________ A30 / P04_6
;                         |_________ A31 / P04_7
;
#set    PFUNC5          B'11111111                  ;<<< select address lines or general purpose port
;                         ||||||||
;                         ||||||||__ A16 / P05_0
;                         |||||||___ A17 / P05_1
;                         ||||||____ A18 / P05_2
;                         |||||_____ A19 / P05_3
;                         ||||______ A20 / P05_4
;                         |||_______ A21 / P05_5
;                         ||________ A22 / P05_6
;                         |_________ A23 / P05_7
;
#set    PFUNC6          B'11111111                  ;<<< select address lines or general purpose port
;                         ||||||||
;                         ||||||||__ A8 / P06_0
;                         |||||||___ A9 / P06_1
;                         ||||||____ A10 / P06_2
;                         |||||_____ A11 / P06_3
;                         ||||______ A12 / P06_4
;                         |||_______ A13 / P06_5
;                         ||________ A14 / P06_6
;                         |_________ A15 / P06_7
;
#set    PFUNC7          B'11111111                  ;<<< select address lines or general purpose port
;                         ||||||||
;                         ||||||||__ A0 / P07_0
;                         |||||||___ A1 / P07_1
;                         ||||||____ A2 / P07_2
;                         |||||_____ A3 / P07_3
;                         ||||______ A4 / P07_4
;                         |||_______ A5 / P07_5
;                         ||________ A6 / P07_6
;                         |_________ A7 / P07_7
;
;==============================================================================
; 4.9.11  Select External bus mode (Control signals)
;==============================================================================
; Select if the following ports are set to
; 1: External bus mode, I/O for control signals or
; 0: General purpose port 
; By default these ports are set to External bus mode
#set    PFUNC8          B'11111111                  ;<<< select control signals or general purpose port
;                         ||||||||
;                         ||||||||__ WRX0 / P08_0
;                         |||||||___ WRX1 / P08_1
;                         ||||||____ WRX2 / P08_2
;                         |||||_____ WRX3 / P08_3
;                         ||||______ RDX / P08_4
;                         |||_______ BGRNTX / P08_5
;                         ||________ BRQ / P08_6
;                         |_________ RDY / P08_7
;
#set    PFUNC9          B'11111111                  ;<<< select address signals or general purpose port
;                         ||||||||
;                         ||||||||__ CSX0 / P09_0
;                         |||||||___ CSX1 / P09_1
;                         ||||||____ CSX2 / P09_2
;                         |||||_____ CSX3 / P09_3
;                         ||||______ CSX4 / P09_4
;                         |||_______ CSX5 / P09_5
;                         ||________ CSX6 / P09_6
;                         |_________ CSX7 / P09_7
;
#set    PFUNC10         B'01011111                  ;<<< select address signals or general purpose port
;                         ||||||||
;                         ||||||||__ SYSCLK or !SYSCLK / P10_0 
;                         |||||||___ ASX / P10_1 
;                         ||||||____ BAAX / P10_2 
;                         |||||_____ WEX / P10_3 
;                         ||||______ MCLKO or !MCLKO / P10_4 
;                         |||_______ MCLKI or !MCLKI/ P10_5 
;                         ||________ MCLKE / P10_6
;                         |_________ - 
;
#set    EPFUNC10        B'00000000                  ;<<< select address lines or general purpose port
;                         ||||||||
;                         ||||||||__ 0:SYSCLK / 1:!SYSCLK
;                         |||||||___ - 
;                         ||||||____ -
;                         |||||_____ -
;                         ||||______ 0:MCLKO / 1:!MCLKO
;                         |||_______ 0:MCLKI / 1:!MCLKI
;                         ||________ 0:MCLKI / 1:!MCLKI
;                         |_________ -
;==============================================================================
; 5  Section and Data Declaration
;==============================================================================

        .export __start             
        .import _main
        .import _RAM_INIT
        .import _ROM_INIT
        
#if CLIBINIT == ON    
        .export __exit 
        .import _exit
        .import __stream_init
#endif

#if CPLUSPLUS == ON
        .export __abort
        .import ___call_dtors
        .import _atexit
#endif
;==============================================================================
; 5.1 Define Stack Size
;==============================================================================
 .SECTION  SSTACK, STACK, ALIGN=4
#if STACK_RESERVE == ON
        .EXPORT         __systemstack, __systemstack_top
 __systemstack:
        .RES.B          STACK_SYS_SIZE
 __systemstack_top: 
#endif
 
        .SECTION  USTACK, STACK, ALIGN=4
#if STACK_RESERVE == ON
         .EXPORT        __userstack, __userstack_top
 __userstack:
        .RES.B          STACK_USR_SIZE
 __userstack_top:
 
#endif
;==============================================================================
; 5.2 Define Sections
;==============================================================================
        .section        DATA,  data,  align=4
        .section        INIT,  data,  align=4
        .section        CONST, const, align=4
        .section        INTVECT, const, align=4 
                 
#if (DEVICE != MB91V460A)
#if (BOOT_FLASH_SEC == OFF) 
        .section        SECURITY_VECTORS, code, locate = 0x148000
        .data.w 0xFFFFFFFF
        .data.w 0xFFFFFFFF
        .data.w 0xFFFFFFFF
        .data.w 0xFFFFFFFF       
#else
        .section        SECURITY_VECTORS, code, locate = 0x148000
        .res.w          4
#endif         
#endif     
   
#if CPLUSPLUS == ON
        .section        EXT_CTOR_DTOR, const, align=4  ; C++ constructors
#endif        
        
;==============================================================================
;6.             S T A R T 
;==============================================================================
;-----------------------------------------------------------
; MACRO Clear RC Watchdog
;-----------------------------------------------------------

#macro  ClearRCwatchdog
		ldi                     #0x4C7,R7       ; clear RC watchdog
		bandl                   #0x7,@R7
#endm
;-----------------------------------------------------------
; MACRO WAIT_LOOP
;-----------------------------------------------------------
#macro wait_loop loop_number
#local _wait64_loop
        ldi             #loop_number, r0
_wait64_loop:
        add             #-1, r0
        bne             _wait64_loop
#endm
        .section        CODE, code, align=4
        .section        CODE_START, code, align=4



__start:                                        ; start point   
;==============================================================================
; NOT RESET YET 
;==============================================================================
startnop: 
        nop       
; If the debugger stays at this NOP after download of applicatioon, the controller has
; not been reset yet. In order to reset all hardware register it is
; highly recommended to reset the controller.
; However, if no reset is used on purpose, this start address can also be used.
; This mechanism is using the .END instruction at the end of this mo-
; dule. It is not necessary for controller operation but improves reliability 
; of debugging (mainly emulator debugger). If the debugger stays here after a
; single step from label "_start" to label "startnop", the note can be ignored.      
        ANDCCR          #0xEF                   ; disable interrupts   
        STILM           #LOW_PRIOR              ; set interrupt level to low prior
        ClearRCwatchdog                         ; clear harware watchdog


#if STACKUSE == SYSSTACK       
        ldi             #__systemstack_top, sp  ; initialize SP
#endif
#if STACKUSE == USRSTACK
        ldi             #__userstack_top, sp    ; initialize SP
#endif

        ldi             #INTVECT, R0            ; set Table Base
smd_tbr: 
        mov             r0, tbr                                                   
;==============================================================================
;6.2     Set Memory Controller
;==============================================================================
        LDI             #0x7002, R1             ; FLASH Controller Reg.
        LDI             #FLASHCONTROL, R2       ; Flash Controller Settings
        STH             R2, @R1                 ; set register
        LDI             #0x7004, R1             ; FLASH Memory Wait Timing Reg.
        LDI             #FLASHREADT, R2         ; wait settings
        STH             R2, @R1                 ; set register
                
        ClearRCwatchdog   
;==============================================================================
;6.3            Check for CSV reset and set CSV
;==============================================================================
#if (CSV & 0x8)
        LDI:20          #0x04AD, R0             ; CSVCR
        BORL            #0x8, @R0               ; Enable Main Osc Supervisor
        BTSTH           #0x4, @R0               ; Check for Main Osc missing
        BEQ             NoMAINCSVreset          ; Main osc available -> branch 
                                                ;   to NoCSVreset
        BANDL           #0x7, @R0               ; Disable Main Osc Supervisor
NoMAINCSVreset: 
#endif
#if (CSV & 0x4)
        BORL            #0x4, @R0               ; Enable Sub Osc Supervisor
        BTSTH           #0x2, @R0               ; Check for Sub Osc missing
        BEQ             NoSUBCSVreset           ; Main osc available -> branch 
                                                ;   to NoCSVreset
        BANDL           #0xB, @R0               ; Disable Sub Osc Supervisor
NoSUBCSVreset:       
#endif      
        LDI             #CSV, R1                ; Load CSVR
        STB             R1, @R0                 ; Set CSVR
;==============================================================================
;6.4            Check reset cause (Operation Reset)
;==============================================================================
        MOV            R4, R0                   ; Check RSRR
        LSR            #0x18, R0                ; RSRR
        BEQ            NO_MB91V460              ; Check V-Chip
        MOV            R0, R4                   ; RSRR
NO_MB91V460:
        LDI:20         #0x08, R2                ; Reset Cause: SRST
        AND            R4, R2
        BNE            no_clock_startup         ; Operation Reset -> No Clock
                                                ;   settings
        LDI:20         #0x10, R2                ; Reset Cause: WD
        AND            R4, R2
        BNE            no_clock_startup         ; Operation Reset -> No Clock
                                                ;   settings
;==============================================================================
; 6.5           Clock startup
;==============================================================================

#if (CLOCKSOURCE != NOCLOCK)
;==============================================================================
; 6.5.1         Power on Clock Modulator - Clock Modulator Part I
;==============================================================================
#if CLOMO == ON
        LDI             #0x04BB, R0             ; Clock Modulator Control Reg
        LDI             #0x11, R1               ; Load value to Power on CM
        ORB             R1, @R0                 ; Power on clock modulaor
#endif

;==============================================================================
; 6.5.2         Set CLKR Register w/o Clock Mode
;==============================================================================
; Set Clock source (Base Clock) for the three clock tree selections
; This select Base clock is used to select afterwards the 3
; Clocks for the diffenrent internal trees.
; When PLL is used, first pll multiplication ratio is set and PLL is
; enabled. After waiting the PLL stabilisation time via timebase
; timer, PLL clock is selected as clock source. 
        LDI             #0x048C, R0             ; PLL Cntl Reg. PLLDIVM/N
        LDI:20          #PLLSPEED, R1
        STH             R1, @R0

        LDI             #0x048E, R0             ; PLL Cntl Reg. PLLDIVG
        LDI             #DIV_G, R1
        STB             R1, @R0

        LDI             #0x048F, R0             ; PLL Cntl Reg. PLLMULG
        LDI             #MUL_G, R1
        STB             R1, @R0

;==============================================================================
; 6.5.3         Start PLL 
;==============================================================================      
#if ( ( CLOCKSOURCE == MAINPLLCLOCK ) || ( PSCLOCKSOURCE == PSCLOCK_PLL ) )
        LDI             #0x0484, R0             ; Clock source control reg CLKR
        LDI             #0x04, R1               ; Use PLL x1, enable PLL 
        ORB             R1, @R0                 ; store data to CLKR register
#endif
       
       
#if ENABLE_SUBCLOCK == ON
        LDI             #0x0484, R0             ; Clock source control reg CLKR
        LDI             #0x08, R1               ; enable subclock operation
        ORB             R1, @R0                 ; store data to CLKR register
#endif      
      
;==============================================================================
; 6.5.4         Wait for PLL oscillation stabilisation
;==============================================================================
#if ((CLOCKSOURCE==MAINPLLCLOCK)||(PSCLOCKSOURCE==PSCLOCK_PLL))
        LDI             #0x0482, R0             ; TimeBaseTimer TBCR
        LDI             #0x10, R1               ; set 128us 
        STB             R1, @R0
        LDI             #0x90, R1               ; set interrupt flag for simulator
        STB             R1, @R0
        
        LDI             #0x0483, R0             ; clearTimeBaseTimer CTBR
        LDI             #0xA5, R1                 
        STB             R1, @R0
        LDI             #0x5A, R1                 
        STB             R1, @R0

        LDI:20          #0x0482, R0
PLLwait:        
        ClearRCwatchdog                         ; clear harware watchdog
        BTSTH           #8, @R0
        BEQ             PLLwait
#endif


;==============================================================================
; 6.5.5         Set clocks 
;==============================================================================

;==============================================================================
; 6.5.5.1       Set CPU and peripheral clock 
;==============================================================================
; CPU and peripheral clock are set in one register
        LDI             #0x0486, R2             ; Set DIVR0 (CPU-clock (CLKB)  
        LDI             #((CPUCLOCK << 4) + PERCLOCK), R3 ; Load CPU clock setting
        STB             R3, @R2               
;==============================================================================
; 6.5.5.2       Set External Bus interface clock
;==============================================================================
; set External Bus clock
; Be aware to do smooth clock setting, to avoid wrong clock setting
; Take care, always write 0 to the lower 4 bits of DIVR1 register
        LDI             #0x0487, R2             ; Set DIVR1  
        LDI             #(EXTBUSCLOCK << 4), R3 ; Load Peripheral clock setting
        STB             R3, @R2 
        
;==============================================================================
; 6.5.5.3       Set CAN clock prescaler
;==============================================================================
; Set CAN Prescaler, only clock relevant parameter 
        LDI             #0x04C0, R0             ; Set CAN ClockParameter Register
        LDI             #(PSCLOCKSOURCE + PSDVC), R1     ; Load Divider
        STB             R1, @R0                          ; Set Divider
; enable CAN clocks
        LDI             #0x04c1, R0             ; Set CAN Clock enable Register
        LDI             #CANCLOCK, R1           ; Load CANCLOCK
        STB             R1, @R0                 ; set CANCLOCK

;==============================================================================
; 6.5.5.4       Switch Main Clock Mode
;==============================================================================
#if CLOCKSOURCE == MAINCLOCK

;==============================================================================
; 6.5.5.5       Switch Subclock Mode
;==============================================================================
#elif ( (CLOCKSOURCE == SUBCLOCK) )
    #if ENABLE_SUBCLOCK == ON
        LDI             #0x0484, R0             ; Clock source control reg CLKR
        LDI             #0x01, R1               ; load value to select main clock
        ORB             R1, @R0                 ; enable main clock (1/2 external) as clock source       
        wait_loop       64                      ; wait
        LDI             #0x03, R1               ; load value to select subclock
        ORB             R1, @R0                 ; enable subclock as clock source       
        wait_loop       64                      ; wait
    #else
        #error: Wrong setting! The clock source is subclock, but the subclock is disabled.
    #endif
       
;==============================================================================
; 6.5.6.6       Switch to PLL Mode
;==============================================================================
#elif ( (CLOCKSOURCE == MAINPLLCLOCK) )

#if (DIV_G != 0x00)
        LDI             #0x0490, R0             ; PLL Ctrl Register   
        LDI             #0x00,R1
        STB             R1, @R0                 ; Clear Flag
        LDI             #0x01,R1
        STB             R1, @R0                 ; Set Flag for Simulator; no Effekt on
#endif                                                ; Emulator
 
        LDI             #0x0484, R3             ; Clock source control reg CLKR
        BORL            #0x2, @R3               ; enable PLL as clock source                                               
                                                
#if (DIV_G != 0x00)                                                
gearUpLoop:    
        ClearRCwatchdog                         ; clear harware watchdog
        LDUB            @R0, R2                 ; LOAD PLLCTR to R2
        AND             R1, R2                  ; GRUP, counter reach 0
        BEQ             gearUpLoop

        LDI             #0x00,R1
        STB             R1, @R0                 ; Clear Gear-Up Flag
#endif         
       
#endif
 
;==============================================================================
; 6.5.7         Enable Frequncy Modulation - Clock Modulator Part II
;==============================================================================
#if CLOMO == ON                                 ; Only applicable if Modulator is on
        LDI             #0x04B8, R0             ; Clock Modulation Parameter Reg
        LDI             #CMPR, R1               ; Load CMP value
        STH             R1, @R0                 ; Store CMP value in CMPR

        LDI             #0x04BB, R0             ; Clock Modulator Control Reg
        LDI             #0x13, R1               ; Load value to FM on CM
        ORB             R1, @R0                 ; FM on 
#endif

#endif
no_clock_startup:

;==============================================================================
;6.6  Set BusInterface
;==============================================================================
#if (EXTBUS)
#if (DEVICE != MB91464A)
;==============================================================================
;6.6.1  Disable all CS
;==============================================================================
        LDI             #0x0680, R3             ; chip select enable register CSER
        LDI             #(0x00), R2 
                                                ; load disable settings    
smd_cs:                                                    
        ANDB            R2, @R3                 ; set register          
;==============================================================================
;6.6.2  Clear TCR Register
;==============================================================================
        LDI             #0x0683, R1             ; Pin/Timing Control Register TCR
        BORH            #0x6,@R1                ; load timing settings 

;==============================================================================
;6.6.3  Set CS0
;==============================================================================
#if CS0
        LDI             #0x0640, R1             ; area select reg ASR0, ACR0      
        LDI             #(AREASEL0<<16)+CONFIGCS0, R0  ; load settings
        ST              R0, @R1                 ; set registers
 
        LDI             #0x660, R1              ; area wait register awr0
        LDI             #WAITREG0, R2           ; wait settings
        STH             R2, @R1                 ; set register
#endif

;==============================================================================
;6.6.4  Set CS1  
;==============================================================================
#if CS1  
        LDI             #0x0644, R1             ; area select reg ASR1, ACR1      
        LDI             #(AREASEL1<<16)+CONFIGCS1, R0  ; load settings
        ST              R0, @R1                 ; set registers

        LDI             #0x662, R1              ; area wait register awr1
        LDI             #WAITREG1, R2           ; wait settings
        STH             R2, @R1                 ; set register
#endif
;==============================================================================
;6.6.5  Set CS2  
;==============================================================================
#if CS2
        LDI             #0x0648, R1             ; area select reg ASR2, ACR2      
        LDI             #(AREASEL2<<16)+CONFIGCS2, R0  ; load settings
        ST              R0, @R1                 ; set registers
        LDI             #0x664, R1              ; area wait register awr2
        LDI             #WAITREG2, R2           ; wait settings
        STH             R2, @R1                 ; set register
#endif
;==============================================================================
;6.6.6  Set CS3  
;==============================================================================
#if CS3
        LDI             #0x064C, R1             ; area select reg ASR3, ACR3      
        LDI             #(AREASEL3<<16)+CONFIGCS3, R0  ; load settings
        ST              R0, @R1                 ; set registers
        LDI             #0x666, R1              ; area wait register awr3
        LDI             #WAITREG3, R2           ; wait settings
        STH             R2, @R1                 ; set register
#endif
;==============================================================================
;6.6.7  Set CS4  
;==============================================================================
#if CS4
        LDI             #0x0650, R1             ; area select reg ASR4, ACR4      
        LDI             #(AREASEL4<<16)+CONFIGCS4, R0  ; load settings
        ST              R0, @R1                 ; set registers
        LDI             #0x668, R1              ; area wait register awr4
        LDI             #WAITREG4, R2           ; wait settings
        STH             R2, @R1                 ; set register
#endif
;==============================================================================
;6.6.8  Set CS5  
;==============================================================================
#if CS5
        LDI             #0x0654, R1             ; area select reg ASR5, ACR5      
        LDI             #(AREASEL5<<16)+CONFIGCS5, R0  ; load settings
        ST              R0, @R1                 ; set registers
        LDI             #0x66A, R1              ; area wait register awr5
        LDI             #WAITREG5, R2           ; wait settings
        STH             R2, @R1                 ; set register
#endif
;==============================================================================
;6.6.9  Set CS6
;==============================================================================
#if (CS6)  
        LDI             #0x0658, R1             ; area select reg ASR6, ACR6      
        LDI             #(AREASEL6<<16)+CONFIGCS6, R0  ; load settings
        ST              R0, @R1                 ; set registers
        LDI             #0x66C, R1              ; area wait register awr6
        LDI             #WAITREG6, R2           ; wait settings
        STH             R2, @R1                 ; set register
#endif
;==============================================================================
;6.6.10  Set CS7  
;==============================================================================
#if CS7
        LDI             #0x065C, R1             ; area select reg ASR7, ACR7     
        LDI             #(AREASEL7<<16)+CONFIGCS7, R0  ; load settings
        ST              R0, @R1                 ; set registers
        LDI             #0x66E, R1              ; area wait register awr7
        LDI             #WAITREG7, R2           ; wait settings
        STH             R2, @R1                 ; set register
#endif             
;==============================================================================
;6.6.11  Set special SDRAM config register  
;==============================================================================
#if (SDRAM)
      #if  CS6 == OFF && CS7 == OFF 
         #error: Wrong SDRAM setting, CS6 and/or CS7 must be used!
      #else
        LDI             #0x670, R1              ; SDRAM memory config register
        LDI             #MEMCON, R2             ; wait settings
        STB             R2, @R1                 ; set register
      #endif
#endif

;==============================================================================
;6.6.12  set Port Function Register
;==============================================================================    
;==============================================================================
;6.6.12.1  set PFR00 Register. External bus mode (D[24-31]) or General purpose port
;==============================================================================    
        LDI             #0x0D80, R1             ; Port Function Register 0, (PFR00)
        LDI             #PFUNC0, R0             ; load port settings 
        STB             R0, @R1                 ; set register    
;==============================================================================
;6.6.12.2  set PFR01 Register. External bus mode (D[16-23]) or General purpose port
;==============================================================================      
        LDI             #0x0D81, R1             ; Port Function Register 1, (PFR01)
        LDI             #PFUNC1, R0             ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.3  set PFR02 Register. External bus mode (D[8-15]) or General purpose port
;==============================================================================      
        LDI             #0x0D82, R1             ; Port Function Register 2, (PFR02)
        LDI             #PFUNC2, R0             ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.4  set PFR03 Register. External bus mode (D[0-7]) or General purpose port
;==============================================================================      
        LDI             #0x0D83, R1             ; Port Function Register 3, (PFR03)
        LDI             #PFUNC3, R0             ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.5  set PFR04 Register. External bus mode (Adr[24-31]) or General purpose port
;==============================================================================      
        LDI             #0x0D84, R1             ; Port Function Register 4, (PFR04)
        LDI             #PFUNC4, R0             ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.6  set PFR05 Register. External bus mode (Adr[16-23]) or General purpose port
;==============================================================================      
        LDI             #0x0D85, R1             ; Port Function Register 5, (PFR05)
        LDI             #PFUNC5, R0             ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.7  set PFR06 Register. External bus mode (Adr[8-15]) or General purpose port
;==============================================================================      
        LDI             #0x0D86, R1             ; Port Function Register 6, (PFR06)
        LDI             #PFUNC6, R0             ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.8  set PFR07 Register. External bus mode (Adr[0-7]) or General purpose port
;==============================================================================      
        LDI             #0x0D87, R1             ; Port Function Register 7, (PFR07)
        LDI             #PFUNC7, R0             ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.9  set PFR08 Register. External bus mode (Control Signals) or General purpose port
;==============================================================================      
        LDI             #0x0D88, R1             ; Port Function Register 8, (PFR08)
        LDI             #PFUNC8, R0             ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.10  set PFR09 Register. External bus mode (Control Signals) or General purpose port
;==============================================================================      
        LDI             #0x0D89, R1             ; Port Function Register 9, (PFR09)
        LDI             #PFUNC9, R0             ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.11  set PFR10 Register. External bus mode (Control Signals) or General purpose port
;==============================================================================      
        LDI             #0x0D8A, R1             ; Port Function Register 10, (PFR10)
        LDI             #PFUNC10, R0            ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.12.12  set EPFR10 Register. External bus mode (Control Signals) or General purpose port
;==============================================================================      
        LDI             #0x0DCA, R1             ; Port Extended Function Register 10, (EPFR10)
        LDI             #EPFUNC10, R0            ; load port settings 
        STB             R0, @R1                 ; set register 
;==============================================================================
;6.6.13  Set TCR Register
;==============================================================================
        LDI             #0x0683, R1             ; Pin/Timing Control Register TCR
        LDI             #TIMECONTR, R0          ; load timing settings 
        STB             R0, @R1                 ; set register

;==============================================================================
;6.6.14  Enable CACHE for selected CS
;==============================================================================
        LDI             #0x0681, R3             ; chip select enable register CSER
        LDI             #CHEENA, R2 
        ORB             R2, @R3      
;==============================================================================
;6.6.15 set SDRAM  Referesh Control Register
;==============================================================================
#if (SDRAM)
        #if  CS6 == OFF && CS7 == OFF 
         #error: Wrong SDRAM setting, CS6 and/or CS7 must be used!
        #else 
        LDI             #0x0684, R1             ; Refresh Control Register RCR
        LDI             #REFRESH, R0            ; load refresh settings 
        STH             R0, @R1                 ; set register    
        LDI             #0x0008, R2
        OR              R2, R0                  ; Set PON bit to 1     
        STH             R0, @R1                 ; set register
        #endif 
#endif

;==============================================================================
;6.6.16  Enable used CS
;==============================================================================
        LDI             #0x0680, R3             ; chip select enable register CSER
        LDI             #ENACSX, R2 
        ORB             R2, @R3
#endif                                          ; #endif (EXTBUS)
        ClearRCwatchdog
;==============================================================================
;6.7  I-cache on/off
;==============================================================================
#if DEVICE == MB91V460A         
    #if CACHE
        #if CACHE_SIZE  == C1024
        LDI             #0x03C7, R1             ; Cache size register ISIZE
        LDI             #0x00, R2
        STB             R2, @R1
        LDI             #0x03E7, R1             ; Cache control reg   ICHCR
        LDI             #0x07, R2               ; Release entry locks, flush and enable 
        STB             R2, @R1                 ; cache  
        #elif CACHE_SIZE  == C2048
        LDI             #0x03C7, R1             ; Cache size register ISIZE
        LDI             #0x01, R2
        STB             R2, @R1
        LDI             #0x03E7, R1             ; Cache control reg   ICHCR
        LDI             #0x07, R2               ; Release entry locks, flush and enable 
        STB             R2, @R1                 ; cache
        #elif CACHE_SIZE  == C4096
        LDI             #0x03C7, R1             ; Cache size register ISIZE
        LDI             #0x02, R2
        STB             R2, @R1
        LDI             #0x03E7, R1             ; Cache control reg   ICHCR
        LDI             #0x07, R2               ; Release entry locks, flush and enable 
        STB             R2, @R1                 ; cache
        #else    
        #error: Wrong Cache size selected!
        #endif          
     #else
        LDI             #0x03E7, R1             ; Cache control reg    ICHCR
        LDI             #0x06, R2               ; Release entry locks, flush and disable
        STB             R2, @R1                 ; cache
#endif
#endif
#endif
;==============================================================================
; Standard C startup
;==============================================================================
;==============================================================================
;6.8  Clear data 
;==============================================================================
;       clear DATA section
; According to ANSI, the DATA section must be cleared during start-up

        ldi:8           #0, r0
        ldi             #sizeof DATA &~0x3, r1
        ldi             #DATA, r13
        cmp             #0, r1
        beq             data_clr1
data_clr0:
        add2            #-4, r1
        bne:d           data_clr0
        st              r0, @(r13, r1)
data_clr1:
        ldi:8           #sizeof DATA & 0x3, r1
        ldi             #DATA + (sizeof DATA & ~0x3), r13

        cmp             #0, r1
        beq             data_clr_end
data_clr2:
        add2            #-1, r1
        bne:d           data_clr2
        stb             r0, @(r13, r1)
data_clr_end:
;==============================================================================
;6.9  Copy Init section from ROM to RAM
;==============================================================================
; copy rom
; All initialised data's (e.g. int i=1) must be stored in ROM/FLASH area. 
; (start value)
; The Application must copy the Section (Init) into the RAM area.
        ldi             #_RAM_INIT, r0
        ldi             #_ROM_INIT, r1
        ldi             #sizeof(INIT), r2
        cmp             #0, r2
        beq:d           copy_rom_end
        ldi             #3, r12
        and             r2, r12
        beq:d           copy_rom2
        mov             r2, r13
        mov             r2, r3
        sub             r12, r3
copy_rom1:
        add             #-1, r13
        ldub            @(r13, r1), r12
        cmp             r3, r13
        bhi:d           copy_rom1
        stb             r12, @(r13, r0)
        cmp             #0, r3
        beq:d           copy_rom_end
copy_rom2:
        add             #-4, r13
        ld              @(r13, r1), r12
        bgt:d           copy_rom2
        st              r12, @(r13, r0)
copy_rom_end:

;==============================================================================
;6.10 C library initialization
;==============================================================================
#if CLIBINIT == ON
       call32          __stream_init, r12         ; initialise library 
#endif
;==============================================================================
;6.11  call C++ constructors
;==============================================================================
#if CPLUSPLUS == ON
       ldi              #___call_dtors, r4
       call32           _atexit, r12

       ldi              #EXT_CTOR_DTOR, r8
       ldi              #EXT_CTOR_DTOR + sizeof(EXT_CTOR_DTOR), r9
       cmp              r9, r8
       beq              L1
L0:
       ld               @r8, r10
       call:d           @r10
       add              #4, r8
       cmp              r9, r8
       bc               L0
L1:
#endif

start_main:
;==============================================================================
;6.12 call main routine
;==============================================================================
       ClearRCwatchdog                            ; clear harware watchdog
       ldi:8            #0, r4                    ; Set the 1st parameter for main to 0.
       call32:d         _main, r12
       ldi:8            #0, r5                    ; Set the 2nd parameter for main to NULL.
#if CLIBINIT == ON
       call32           _exit, r12
       __exit:
#endif

#if CPLUSPLUS == ON
       __abort:
#endif


;==============================================================================
;6.13  Return from main function
;==============================================================================
end: 
        bra             end  
        .end            __start