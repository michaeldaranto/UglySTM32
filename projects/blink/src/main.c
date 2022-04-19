#include "stm32f4xx.h"

// Quick and dirty delay
static void delay (unsigned int time) {
    for (unsigned int i = 0; i < time; i++)
        for (volatile unsigned int j = 0; j < 2000; j++);
}

int main (void) {
    // Turn on the GPIOC peripheral
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
    
    // Set GPIOC Pin 13 Output
    GPIOC->MODER|= GPIO_MODER_MODE13_0;
    GPIOC->MODER&=~GPIO_MODER_MODE13_1;

    while (1) {
	GPIOC->ODR ^=GPIO_ODR_OD13; //(1<<13);
        delay(140);
    }

    // Return 0 to satisfy compiler
    return 0;
}
