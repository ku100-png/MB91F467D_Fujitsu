/* THIS SAMPLE CODE IS PROVIDED AS IS AND IS SUBJECT TO ALTERATIONS. FUJITSU */
/* MICROELECTRONICS ACCEPTS NO RESPONSIBILITY OR LIABILITY FOR ANY ERRORS OR */
/* ELIGIBILITY FOR ANY PURPOSES.                                             */
/*                 (C) Fujitsu Microelectronics Europe GmbH                  */
/*------------------------------------------------------------------------
  MAIN.C
  - description
  - See README.TXT for project description and disclaimer.

----------------------------------------------------------------------*/
 
/*************************@INCLUDE_START************************/
#include "mb91467d.h"

/**************************@INCLUDE_END*************************/

/*********************@GLOBAL_VARIABLES_START*******************/
unsigned char c;
/**********************@GLOBAL_VARIABLES_END********************/

/*******************@FUNCTION_DECLARATION_START*****************/
void			int2_init (void);
void 			led_init (void);
void 			spi_init (void);
void 			spi_cs_enable (void); 
void 			spi_cs_disable (void); 
void 			spi_tx_8Bit (unsigned char byte) ;
unsigned char 	spi_rx_8Bit (void);
/********************@FUNCTION_DECLARATION_END******************/

void int2_init (void) {
	ENIR0_EN2 = 1;
            
    PFR24_D2 = 1; DDR24_D2 = 0; /* INT 2 */
      
    ELVR0_LA2 = 0; ELVR0_LB2 = 1;
}

/*********************@FUNCTION_HEADER_START*********************
*@FUNCTION NAME:    led_init ()                                 *
*                                                               *
*@DESCRIPTION:                                                  *
*                                                               *
*@PARAMETER:        none                                        *
*                                                               *
*@RETURN:           none                                        *
*                                                               *
***********************@FUNCTION_HEADER_END*********************/
void led_init (void) {
	
	DDR16 = 0xff;
    PFR16 = 0x00;
    PDR16 = 0x00;

}

/*********************@FUNCTION_HEADER_START*********************
*@FUNCTION NAME:    spi_init ()                                 *
*                                                               *
*@DESCRIPTION:                                                  *
*                                                               *
*@PARAMETER:        none                                        *
*                                                               *
*@RETURN:           none                                        *
*                                                               *
***********************@FUNCTION_HEADER_END*********************/
void spi_init (void) {

	SCR05_TXE 	= 1;		/* enable transmission */
	SCR05_RXE 	= 1;		/* enable reception */

	SCR05_CL	= 1;		/* 8 Data Bits */
	SCR05_PEN	= 0;		/* Parity disbled */
		
	ESCR05_SCES	= 0;		/* Sampling on rising clock edge (normal) */
	
	ECCR05_SCDE	= 0;
	
	ESCR05_CCO	= 0;		/* Continuous Clock Output disabled */
	
	ECCR05_SSM	= 0;		/* disable Start, Stop Bit in synchr. mode */
	ECCR05_MS	= 0;		/* Master mode */
	
	SSR05_BDS	= 1;		/* MSB first */
	SSR05_RIE	= 1;		/* Reception interrupts enabled */
	SSR05_TIE	= 0;		/* Transmission interrupts disabled */
	
	SMR05_SOE	= 1; 		/* enable serial in/output */
	SMR05_SCKE	= 1;		/* enable serial clock output */
	SMR05_MD	= 2;		/* synchronous mode */
	SMR05_EXT	= 0;		/* Use internal Baud Rate Generator (Reload Counter) */
	
	BGR05 		= 1666;		/* select baudrate [CLKP / baudrate] - 1 -> 9600baud*/
	
	DDR18_D0	= 1;		/* select as ouput */
	PFR18_D0	= 0;		/* use GPIO function */
	PDR18_D0	= 1;		/* CS = 0 */
	
	PFR19_D6	= 1;		/* use resource function */
	EPFR19_D6	= 0;		/* resource function SCK4 */
	PFR19_D4	= 1;		/* use resource function SOT4*/

	PFR19_D5	= 1;		/* use resource function SIN4*/
	
}


/*********************@FUNCTION_HEADER_START*********************
*@FUNCTION NAME:    spi_rx_8Bit ()                              *
*                                                               *
*@DESCRIPTION:      Receives one byte from SPI in polling mode  *
*                                                               *
*@PARAMETER:        none                                        *
*                                                               *
*@RETURN:           unsigned char                               *
*                   Received Byte from SPI                      *
*                                                               *
***********************@FUNCTION_HEADER_END*********************/
unsigned char spi_rx_8Bit (void) {
	
	while (SSR05_RDRF == 0) {HWWD_CL = 0;}	/* wait for next received byte */

	return RDR05;	

}

/*********************@FUNCTION_HEADER_START*********************
*@FUNCTION NAME:    spi_tx_8Bit ()                              *
*                                                               *
*@DESCRIPTION:      Transmit one byte in polling mode           *
*                                                               *
*@PARAMETER:        unsigned char byte                          *
*                   Byte to be transmitted over SPI             *
*                                                               *
*@RETURN:           none                                        *
*                                                               *
***********************@FUNCTION_HEADER_END*********************/
void spi_tx_8Bit (unsigned char byte) {
		
	while (SSR05_TDRE == 0) {HWWD_CL = 0;}  // wait for free transmitting buffer 
    TDR05 = byte;                           // transmit next byte 

	while (ECCR05 & 0x01) {HWWD_CL = 0;}    // wait for start of transmission (or ongoing) 
	while (!(ECCR05 & 0x01)) {HWWD_CL = 0;} // wait for transmission finished
		
}

/*********************@FUNCTION_HEADER_START*********************
*@FUNCTION NAME:    spi_cs_enable ()                            *
*                                                               *
*@DESCRIPTION:      Enables the Chip Select                     *
*                                                               *
*@PARAMETER:        											*
*                                                               *
*@RETURN:           none                                        *
*                                                               *
***********************@FUNCTION_HEADER_END*********************/
void spi_cs_enable (void) {

	PDR18_D0 = 0;				/* CS = 1 */
	
}

/*********************@FUNCTION_HEADER_START*********************
*@FUNCTION NAME:    spi_cs_disable ()                            *
*                                                               *
*@DESCRIPTION:      Enables the Chip Select                     *
*                                                               *
*@PARAMETER:        											*
*                                                               *
*@RETURN:           none                                        *
*                                                               *
***********************@FUNCTION_HEADER_END*********************/
void spi_cs_disable (void) {

	PDR18_D0 = 1;				/* CS = 0 */
	
}

/*********************@FUNCTION_HEADER_START*********************
*@FUNCTION NAME:    main()                                      *
*                                                               *
*@DESCRIPTION:      The main function controls the program flow *
*                                                               *
*@PARAMETER:        none                                        *
*                                                               *
*@RETURN:           none                                        *
*                                                               *
***********************@FUNCTION_HEADER_END*********************/


void main(void)
{

	int2_init ();
	led_init ();			   /* init LEDs */
	spi_init (); 			   /* init SPI */

    __EI();                    /* enable interrupts */
    __set_il(31);              /* allow all levels */
    InitIrqLevels();           /* init interrupts */

    PORTEN = 0x3;              /* enable I/O Ports */
                               /* This feature is not supported by MB91V460A */
                               /* For all other devices the I/O Ports must be enabled*/
 
	c = 0x00;
	
    while(1)                   /* endless loop */
    {    
         
       HWWD_CL = 0;   
       
       /* feed hardware watchdog */
       /* (Only for devices with hardware (R/C based) watchdog) */
       /* The hardware (R/C based) watchdog is started */
       /* automatically after power-up and can not be stopped */
       /* If the hardware watchdog is not cleared frequently */
       /* a reset is generated. */           
    }   
}


__interrupt void USARTRxIRQHandler (void) {

	PDR16 = RDR05;		/* show received byte on LED port */
						/* interrupt flag is cleared by reading RDR */				
}

__interrupt void Ext2IRQHandler (void) {

    spi_cs_enable ();		    /* enable CS */
    spi_tx_8Bit (c++);	   		/* transmit first 8 bit */
    spi_cs_disable ();		    /* disable CS */   
    EIRR0_ER2 = 0;

}
