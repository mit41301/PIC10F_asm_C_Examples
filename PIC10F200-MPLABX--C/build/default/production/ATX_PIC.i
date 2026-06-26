# 1 "ATX_PIC.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 288 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\language_support.h" 1 3
# 2 "<built-in>" 2
# 1 "ATX_PIC.c" 2
# 21 "ATX_PIC.c"
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdio.h" 1 3



# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\__size_t.h" 1 3



typedef unsigned size_t;
# 4 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdio.h" 2 3

# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\__null.h" 1 3
# 5 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdio.h" 2 3






# 1 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdarg.h" 1 3






typedef void * va_list[1];

#pragma intrinsic(__va_start)
extern void * __va_start(void);

#pragma intrinsic(__va_arg)
extern void * __va_arg(void *, ...);
# 11 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdio.h" 2 3
# 43 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdio.h" 3
struct __prbuf
{
 char * ptr;
 void (* func)(char);
};
# 85 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdio.h" 3
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\conio.h" 1 3







# 1 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\errno.h" 1 3
# 29 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\errno.h" 3
extern int errno;
# 8 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\conio.h" 2 3




extern void init_uart(void);

extern char getch(void);
extern char getche(void);
extern void putch(char);
extern void ungetch(char);

extern __bit kbhit(void);



extern char * cgets(char *);
extern void cputs(const char *);
# 85 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdio.h" 2 3



extern int cprintf(char *, ...);
#pragma printf_check(cprintf)



extern int _doprnt(struct __prbuf *, const register char *, register va_list);
# 180 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdio.h" 3
#pragma printf_check(vprintf) const
#pragma printf_check(vsprintf) const

extern char * gets(char *);
extern int puts(const char *);
extern int scanf(const char *, ...) __attribute__((unsupported("scanf() is not supported by this compiler")));
extern int sscanf(const char *, const char *, ...) __attribute__((unsupported("sscanf() is not supported by this compiler")));
extern int vprintf(const char *, va_list) __attribute__((unsupported("vprintf() is not supported by this compiler")));
extern int vsprintf(char *, const char *, va_list) __attribute__((unsupported("vsprintf() is not supported by this compiler")));
extern int vscanf(const char *, va_list ap) __attribute__((unsupported("vscanf() is not supported by this compiler")));
extern int vsscanf(const char *, const char *, va_list) __attribute__((unsupported("vsscanf() is not supported by this compiler")));

#pragma printf_check(printf) const
#pragma printf_check(sprintf) const
extern int sprintf(char *, const char *, ...);
extern int printf(const char *, ...);
# 22 "ATX_PIC.c" 2
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdlib.h" 1 3






typedef unsigned short wchar_t;







typedef struct {
 int rem;
 int quot;
} div_t;
typedef struct {
 unsigned rem;
 unsigned quot;
} udiv_t;
typedef struct {
 long quot;
 long rem;
} ldiv_t;
typedef struct {
 unsigned long quot;
 unsigned long rem;
} uldiv_t;
# 65 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdlib.h" 3
extern double atof(const char *);
extern double strtod(const char *, const char **);
extern int atoi(const char *);
extern unsigned xtoi(const char *);
extern long atol(const char *);



extern long strtol(const char *, char **, int);

extern int rand(void);
extern void srand(unsigned int);
extern void * calloc(size_t, size_t);
extern div_t div(int numer, int denom);
extern udiv_t udiv(unsigned numer, unsigned denom);
extern ldiv_t ldiv(long numer, long denom);
extern uldiv_t uldiv(unsigned long numer,unsigned long denom);



extern unsigned long _lrotl(unsigned long value, unsigned int shift);
extern unsigned long _lrotr(unsigned long value, unsigned int shift);
extern unsigned int _rotl(unsigned int value, unsigned int shift);
extern unsigned int _rotr(unsigned int value, unsigned int shift);




extern void * malloc(size_t);
extern void free(void *);
extern void * realloc(void *, size_t);




# 1 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\xc8debug.h" 1 3
# 13 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\xc8debug.h" 3
#pragma intrinsic(__builtin_software_breakpoint)
extern void __builtin_software_breakpoint(void);
# 99 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdlib.h" 2 3





extern int atexit(void (*)(void));
extern char * getenv(const char *);
extern char ** environ;
extern int system(char *);
extern void qsort(void *, size_t, size_t, int (*)(const void *, const void *));
extern void * bsearch(const void *, void *, size_t, size_t, int(*)(const void *, const void *));
extern int abs(int);
extern long labs(long);

extern char * itoa(char * buf, int val, int base);
extern char * utoa(char * buf, unsigned val, int base);




extern char * ltoa(char * buf, long val, int base);
extern char * ultoa(char * buf, unsigned long val, int base);

extern char * ftoa(float f, int * status);
# 23 "ATX_PIC.c" 2
# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\xc.h" 1 3
# 18 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\xc.h" 3
extern const char __xc8_OPTIM_SPEED;

extern double __fpnormalize(double);




# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\builtins.h" 1 3



# 1 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 1 3
# 13 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef signed char int8_t;






typedef signed int int16_t;







typedef __int24 int24_t;







typedef signed long int int32_t;
# 52 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef unsigned char uint8_t;





typedef unsigned int uint16_t;






typedef __uint24 uint24_t;






typedef unsigned long int uint32_t;
# 88 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef signed char int_least8_t;







typedef signed int int_least16_t;
# 109 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef __int24 int_least24_t;
# 118 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef signed long int int_least32_t;
# 136 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef unsigned char uint_least8_t;






typedef unsigned int uint_least16_t;
# 154 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef __uint24 uint_least24_t;







typedef unsigned long int uint_least32_t;
# 181 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef signed char int_fast8_t;






typedef signed int int_fast16_t;
# 200 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef __int24 int_fast24_t;







typedef signed long int int_fast32_t;
# 224 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef unsigned char uint_fast8_t;





typedef unsigned int uint_fast16_t;
# 240 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef __uint24 uint_fast24_t;






typedef unsigned long int uint_fast32_t;
# 268 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef int32_t intmax_t;
# 282 "C:\\Program Files\\Microchip\\xc8\\v2.32\\pic\\include\\c90\\stdint.h" 3
typedef uint32_t uintmax_t;






typedef int16_t intptr_t;




typedef uint16_t uintptr_t;
# 5 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\builtins.h" 2 3


#pragma intrinsic(__nop)
extern void __nop(void);


#pragma intrinsic(_delay)
extern __attribute__((nonreentrant)) void _delay(uint32_t);
#pragma intrinsic(_delaywdt)
extern __attribute__((nonreentrant)) void _delaywdt(uint32_t);
# 25 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\xc.h" 2 3



# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\pic.h" 1 3




# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\htc.h" 1 3



# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\xc.h" 1 3
# 5 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\htc.h" 2 3
# 6 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\pic.h" 2 3







# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\pic_chip_select.h" 1 3
# 44 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\pic_chip_select.h" 3
# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 1 3
# 45 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 3
# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\__at.h" 1 3
# 46 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 2 3







extern volatile unsigned char INDF __attribute__((address(0x000)));

__asm("INDF equ 00h");


typedef union {
    struct {
        unsigned INDF :8;
    };
} INDFbits_t;
extern volatile INDFbits_t INDFbits __attribute__((address(0x000)));
# 73 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 3
extern volatile unsigned char TMR0 __attribute__((address(0x001)));

__asm("TMR0 equ 01h");


typedef union {
    struct {
        unsigned TMR0 :8;
    };
} TMR0bits_t;
extern volatile TMR0bits_t TMR0bits __attribute__((address(0x001)));
# 93 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 3
extern volatile unsigned char PCL __attribute__((address(0x002)));

__asm("PCL equ 02h");


typedef union {
    struct {
        unsigned PCL :8;
    };
} PCLbits_t;
extern volatile PCLbits_t PCLbits __attribute__((address(0x002)));
# 113 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 3
extern volatile unsigned char STATUS __attribute__((address(0x003)));

__asm("STATUS equ 03h");


typedef union {
    struct {
        unsigned C :1;
        unsigned DC :1;
        unsigned Z :1;
        unsigned nPD :1;
        unsigned nTO :1;
        unsigned :2;
        unsigned GPWUF :1;
    };
    struct {
        unsigned CARRY :1;
        unsigned :1;
        unsigned ZERO :1;
    };
} STATUSbits_t;
extern volatile STATUSbits_t STATUSbits __attribute__((address(0x003)));
# 179 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 3
extern volatile unsigned char FSR __attribute__((address(0x004)));

__asm("FSR equ 04h");


typedef union {
    struct {
        unsigned FSR :8;
    };
} FSRbits_t;
extern volatile FSRbits_t FSRbits __attribute__((address(0x004)));
# 199 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 3
extern volatile unsigned char OSCCAL __attribute__((address(0x005)));

__asm("OSCCAL equ 05h");


typedef union {
    struct {
        unsigned FOSC4 :1;
        unsigned CAL :7;
    };
    struct {
        unsigned :1;
        unsigned CAL0 :1;
        unsigned CAL1 :1;
        unsigned CAL2 :1;
        unsigned CAL3 :1;
        unsigned CAL4 :1;
        unsigned CAL5 :1;
        unsigned CAL6 :1;
    };
} OSCCALbits_t;
extern volatile OSCCALbits_t OSCCALbits __attribute__((address(0x005)));
# 270 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 3
extern volatile unsigned char GPIO __attribute__((address(0x006)));

__asm("GPIO equ 06h");


typedef union {
    struct {
        unsigned GP0 :1;
        unsigned GP1 :1;
        unsigned GP2 :1;
        unsigned GP3 :1;
    };
} GPIObits_t;
extern volatile GPIObits_t GPIObits __attribute__((address(0x006)));
# 308 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 3
extern volatile __control unsigned char OPTION __attribute__((address(0x000)));



extern volatile __control unsigned char TRIS __attribute__((address(0x006)));



extern volatile __control unsigned char TRISGPIO __attribute__((address(0x006)));
# 343 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\proc\\pic10f200.h" 3
extern volatile __bit CAL0 __attribute__((address(0x29)));


extern volatile __bit CAL1 __attribute__((address(0x2A)));


extern volatile __bit CAL2 __attribute__((address(0x2B)));


extern volatile __bit CAL3 __attribute__((address(0x2C)));


extern volatile __bit CAL4 __attribute__((address(0x2D)));


extern volatile __bit CAL5 __attribute__((address(0x2E)));


extern volatile __bit CAL6 __attribute__((address(0x2F)));


extern volatile __bit CARRY __attribute__((address(0x18)));


extern volatile __bit DC __attribute__((address(0x19)));


extern volatile __bit FOSC4 __attribute__((address(0x28)));


extern volatile __bit GP0 __attribute__((address(0x30)));


extern volatile __bit GP1 __attribute__((address(0x31)));


extern volatile __bit GP2 __attribute__((address(0x32)));


extern volatile __bit GP3 __attribute__((address(0x33)));


extern volatile __bit GPWUF __attribute__((address(0x1F)));


extern volatile __bit ZERO __attribute__((address(0x1A)));


extern volatile __bit nPD __attribute__((address(0x1B)));


extern volatile __bit nTO __attribute__((address(0x1C)));
# 45 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\pic_chip_select.h" 2 3
# 14 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\pic.h" 2 3
# 76 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\pic.h" 3
__attribute__((__unsupported__("The " "FLASH_READ" " macro function is no longer supported. Please use the MPLAB X MCC."))) unsigned char __flash_read(unsigned short addr);

__attribute__((__unsupported__("The " "FLASH_WRITE" " macro function is no longer supported. Please use the MPLAB X MCC."))) void __flash_write(unsigned short addr, unsigned short data);

__attribute__((__unsupported__("The " "FLASH_ERASE" " macro function is no longer supported. Please use the MPLAB X MCC."))) void __flash_erase(unsigned short addr);



# 1 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\eeprom_routines.h" 1 3
# 84 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\pic.h" 2 3
# 118 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\pic.h" 3
extern __bank0 unsigned char __resetbits;
extern __bank0 __bit __powerdown;
extern __bank0 __bit __timeout;
# 29 "C:/Program Files/Microchip/MPLABX/v6.00/packs/Microchip/PIC10-12Fxxx_DFP/1.5.61/xc8\\pic\\include\\xc.h" 2 3
# 24 "ATX_PIC.c" 2


#pragma config WDTE=OFF, CP = OFF, OSC=IntRC, MCLRE = OFF
# 37 "ATX_PIC.c"
typedef union {
    struct {
        unsigned char FREQ_SEL :1;
        unsigned char TICK_OUT_SW :1;
        unsigned char PWR_ON :1;
        unsigned char ON_OFF :1;
    };
} GPIObits_type;

extern volatile GPIObits_type GPIObitss __attribute__((address(0x006)));
# 61 "ATX_PIC.c"
unsigned char Tick_state=0;
unsigned char Tick_Freq=0;
unsigned char temp=0;
unsigned char Pwr_state=1;
unsigned char Switch_Type=0x10;
unsigned char KeyPressTime=0;
unsigned char ButTimeOut=0;






void picinit(void)
{
    OPTION = 0x85;
    TRISGPIO = 0xB;
    GPIO=0x7;
    TMR0 = 0;

    temp=(GPIObitss.FREQ_SEL);
    if (temp==1)
    {
        Tick_Freq = 126;
    }
    else
    {
        Tick_Freq = 100;
    }
    temp=(GPIObitss.TICK_OUT_SW);
    if (temp==1)
    {
        Switch_Type = 0x24;
    }
    else
    {
        Switch_Type = 0x10;
    }
     TRISGPIO = 0x9;

    TMR0=Tick_Freq;

    }






void main(void) {
    unsigned char tmr0_val;
    picinit();
    while(1)
    {
        tmr0_val=TMR0;
        if (tmr0_val==0)
        {

            Tick_state = !Tick_state;
            GPIObitss.TICK_OUT_SW = Tick_state;
            TMR0=Tick_Freq;

           if (GPIObitss.ON_OFF==0 & Switch_Type == 0x10 )
            {
                 GPIObitss.PWR_ON = 0;
            }
            else if (GPIObitss.ON_OFF==1 & Switch_Type == 0x10 )
            {
                GPIObitss.PWR_ON = 1;
            }
            else if (GPIObitss.ON_OFF==0 & Switch_Type == 0x24 )
            {
                KeyPressTime++;
            }
            if (KeyPressTime > 50)
            {
                ButTimeOut++;
                if (Pwr_state==1)
                {
                    GPIObitss.PWR_ON = 0;
                }
                else
                {
                    GPIObitss.PWR_ON = 1;
                }
             }

            if (GPIObitss.ON_OFF==1 & KeyPressTime>50 & ButTimeOut>30)
            {
               if (Pwr_state==1)
                {
                    Pwr_state=0;
                }
                else
                {
                    Pwr_state=1;
                }

                KeyPressTime=0;
                ButTimeOut=0;
            }
        }
    }
}
