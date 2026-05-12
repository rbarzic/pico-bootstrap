#include <stdio.h>
#include "pico/stdlib.h"

int main() {
    stdio_uart_init_full(uart0, 115200, 0, 1);  // GP0=TX, GP1=RX

    printf("@PROJECT_NAME@ started\n");

    while (true) {
        tight_loop_contents();
    }
}
