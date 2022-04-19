#include "stm32f4xx.h"

// Quick and dirty delay
static void delay (unsigned int time) {
    for (unsigned int i = 0; i < time; i++)
        for (volatile unsigned int j = 0; j < 2000; j++);
}

int main (void) {
    // Turn on the GPIOC & GPIOA peripheral
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    
    GPIOA->MODER&=~GPIO_MODER_MODE0; 	//GPIOA Pin 0 input
    
    GPIOC->MODER|= GPIO_MODER_MODE13_0; //GPIOC Pin 13 output
    GPIOC->MODER&=~GPIO_MODER_MODE13_1;
    

    while (1) {
    
	if (GPIOA->IDR&GPIO_IDR_ID0) {
	GPIOC->ODR ^=(1<<13);
	delay(20);
	}
	else {
	GPIOC->ODR ^=(1<<13);
        delay(100);
        }
    }

    // Return 0 to satisfy compiler
    return 0;
}
