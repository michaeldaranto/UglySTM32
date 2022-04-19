#include "stm32f4xx.h"

}

int main (void) {
    // Turn on the GPIOC peripheral
    RCC->RCC_CR |=RCC_CR_HSEON;
    while(1) (RCC->RCC_CR=!RCC_CR_HSERDY);
    RCC->RCC_PLL |=RCC_CR_PLLON;
    while(1) (RCC->RCC_CR=!RCC_CR_PLLRDY);
    
        
    while (1) {

	GPIOC->ODR ^=GPIO_ODR_OD13; //(1<<13);
        delay(140);

    }

    // Return 0 to satisfy compiler
    return 0;
}
