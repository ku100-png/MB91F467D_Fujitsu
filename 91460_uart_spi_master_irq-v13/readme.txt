==========================================================================
                   Template Project for MB91F467D 
==========================================================================
                   Fujitsu Microelectronics Europe GmbH                       
                 http://emea.fujitsu.com/microelectronics 
                                                            
 The following  software  is for  demonstration  purposes only.  It is not
 fully  tested, nor validated  in order  to fullfill  its task  under  all
 circumstances.  Therefore,  this software or  any part of it must only be
 used in an evaluation laboratory environment.                        
 This software is subject to the rules of our standard DISCLAIMER, that is
 delivered with our  SW-tools on the Fujitsu Microcontrollers CD 
 (V3.4 or higher "\START.HTM") or on our Internet Pages:
 http://www.fme.gsdc.de/gsdc.htm
 http://emea.fujitsu.com/microelectronics 
==========================================================================
               
History
Date      Ver   Author  Softune   Description
11.11.05  1.0   OGl     V60L05R05 initial version
20.12.05  1.1   UMa     V60L05R05 based on template v1.3
27.03.06  1.2   OGl     V60L05R05 Update based on template v16:
                                  New Headerfile,Start91460.asm changed
                                  vectors.c changed
                                  Support of monitor Debugger in ext. Flash
15.11.06  1.3   UMa     V60L06    Wait for transmission finished

==========================================================================

This is a SPI project for the MB91F467D Series. It includes some basic 
settings for e.g. Linker, C-Compiler which must be checked and modified in 
detail, corresponding to the user application.

Description:
This project gives an introduction of initializing the USART interface of the MB91F467D
for synchronous transmission via channel 4 with usage of interrupts.
This sample initializes the SPI with following parameters:
	Mode 		= Master mode
	Baudrate	= 9600 baud
	Channel		= 5
	Port 		= P19_{D4=SIN, D5=SOT, D6=SCK} 18_{D0=CS} 
For demonstration there is a transfer of 8 bits that is triggert by the external interrupt 2.
The data reception is implemented with use of the uart rx interrupt.


Connection (w/o power supply):

Slave                       MCU

+---------+                +----------+
|      DI |<---------------| SOTx     |
|      DO |--------------->| SINx     |
|      SK |<---------------| SCKx     |
|      CS |<---------------| Px       |
|         |                |          |
|         |                |          |
+---------+                +----------+

Timing:
            __                                   _____
CS            |_________________________________|
            ____   _   _   _   _   _   _   _   _____ 
SCK             |_| |_| |_| |_| |_| |_| |_| |_| 
                 ___ ___ ___ ___ ___ ___ ___ ___
SOT         ----<___X___X___X___X___X___X___X___>---


Note 1: Only for devices with hardware watchdog (R/C based watchdog) 
        The hardware (R/C based) watchdog is started automatically 
        after power-up and can not be stopped. If the hardware wotchdog 
        is not cleared frequently a reset is generated. 
        
        For ICE and 91460 addapter board (MB2198-300) only: 
        The hardware watchdog can be disabled
        1) by the softune work bench 
        (Start Debugger -> Setup -> Dev. Enviroment -> Dev. Enviroment
           -> Execution -> watchdog
        2) by the 91460 addapter board (MB2198-300)
           Jumper HWWDG_KILL
        To enable the hardware watchdog, check both the hardware and the 
        software setting.
        
Note 2: The I/O Ports must be generally be enabled by the register PORTEN.
        Only the mb91V460 does not support this feature.

