/* 
 * File:   ATX_PIC.c
 * Author: Ian Stedman
 *
 * Created on 3rd November 2014
 * Updated 28th June 2022 to support MPLAB 6/XC8 V2.32
 * I/O Config
 * Pin 1 GP0 FREQ_SEL n50/60Hz
 * Pin 3 GP1 TICK output
 * Pin 4 GP2 PWR_ON
 * Pin 6 GP3 On/Off input (disable MCLR in software)
 *
 * Software description
 * ATX power supply PIC and tick generator
 * This device de-bounces a switch and drives the PS-ON discrete of an ATX PSU.
 * It also generates a 50/60Hz Tick signal using the builtin timer.
 * Every 10000 cycles (for 50 Hz) or 8333 cycles (for 60Hz) generate either edge
 * of a tick clock.
 */

#include <stdio.h>
#include <stdlib.h>
#include <xc.h>

#define _XTAL_FREQ 4000000  // Used for simulation
#pragma config WDTE=OFF, CP = OFF, OSC=IntRC, MCLRE = OFF

#define TICK50 100  // count of 100 clock cycles for a timer /64 and using 1us internal CPU timing
#define TICK60 126 // count of 126 clock cycles for a timer /64 and using 1us internal CPU timing
#define POWER_ON 0
#define POWER_OFF 1
#define LAT_SWITCH 0x10
#define MOM_SWITCH 0x24
#define SWITCH_DEBOUNCE 50  // 500ms at 10ms loop.
// I/O defines

typedef union {
    struct {
        unsigned char FREQ_SEL                  :1;  // bit 0
        unsigned char TICK_OUT_SW               :1;  // bit 1
        unsigned char PWR_ON                    :1;  // bit 2
        unsigned char ON_OFF                    :1;  // bit 3
    };
} GPIObits_type;

extern volatile GPIObits_type GPIObitss __at (0x006);

/*
typedef union {
    struct {
        unsigned GP0                    :1;
        unsigned GP1                    :1;
        unsigned GP2                    :1;
        unsigned GP3                    :1;
    };
} GPIObits_t;
extern volatile GPIObits_t GPIObits __at(0x006);
*/


unsigned char Tick_state=0;
unsigned char Tick_Freq=0;     // Give it a default
unsigned char temp=0;
unsigned char Pwr_state=POWER_OFF;
unsigned char Switch_Type=LAT_SWITCH; // Set something valid
unsigned char KeyPressTime=0;
unsigned char ButTimeOut=0;





/* Hardware init for PIC10F*/
void picinit(void)
{
    OPTION = 0x85;  // Disable wake on pin, enable pull-ups, set timer 0 internal, prescaler /64
    TRISGPIO = 0xB; // Set GP2 as output and GP0, GP1 & GP3/MCLR as input
    GPIO=0x7;       // Switch I/O off
    TMR0 = 0;       // Clear timer 0
//    CMCON0 = 0x73;     // Comparator disabled
    temp=(GPIObitss.FREQ_SEL);
    if (temp==1)    // 60 Hz
    {
        Tick_Freq = TICK60;
    }
    else
    {
        Tick_Freq = TICK50;
    }
    temp=(GPIObitss.TICK_OUT_SW);
    if (temp==1)        
    {
        Switch_Type = MOM_SWITCH;
    }
    else 
    {
        Switch_Type = LAT_SWITCH;
    }
     TRISGPIO = 0x9; // Set GP1 and GP2 as output and GP0 & GP3/MCLR as input

    TMR0=Tick_Freq;    // Pre-load Timer 0

    }



/*
 * For the moment, assume momentary ATX switch only
 */
void main(void) {
    unsigned char tmr0_val;
    picinit();
    while(1)        
    {
        tmr0_val=TMR0;
        if (tmr0_val==0)
        {
            //Tick_state = ((!Tick_state) & 0x2) >>1;   // Invert last stored value
            Tick_state = !Tick_state;   // Invert last stored value
            GPIObitss.TICK_OUT_SW = Tick_state;
            TMR0=Tick_Freq;

           if (GPIObitss.ON_OFF==0 & Switch_Type == LAT_SWITCH )
            {
                 GPIObitss.PWR_ON = POWER_ON;
            }
            else if (GPIObitss.ON_OFF==1 & Switch_Type == LAT_SWITCH )
            {
                GPIObitss.PWR_ON = POWER_OFF;
            }
            else if (GPIObitss.ON_OFF==0 & Switch_Type == MOM_SWITCH ) // Switch closed
            {
                KeyPressTime++;
            }
            if (KeyPressTime > SWITCH_DEBOUNCE)   // Switch held long enough
            {
                ButTimeOut++;
                if (Pwr_state==POWER_OFF)
                {
                    GPIObitss.PWR_ON = POWER_ON;   // Output 0 to switch on PSU
                }
                else
                {
                    GPIObitss.PWR_ON = POWER_OFF;   // Output 1 to switch off PSU
                }
             } // Keypress > value

            if (GPIObitss.ON_OFF==1 & KeyPressTime>SWITCH_DEBOUNCE & ButTimeOut>30) // Switch released
            {
               if (Pwr_state==POWER_OFF)
                {
                    Pwr_state=POWER_ON;
                }
                else
                {
                    Pwr_state=POWER_OFF;
                }

                KeyPressTime=0;
                ButTimeOut=0;
            }
        }   // end main timer loop
    }   // end while(1)
}   // end main()

