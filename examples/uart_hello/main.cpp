#include <stdio.h>
#include "pico/stdlib.h"

int main() {
    // UART0 on GP0 (TX) / GP1 (RX) at 115200 — matches Debug Probe default
    stdio_uart_init_full(uart0, 115200, 0, 1);

    uint32_t count = 0;
    while (true) {
        printf("Hello from Pico! count=%lu\n", count++);

        // Echo any received characters back
        int c = getchar_timeout_us(0);
        if (c != PICO_ERROR_TIMEOUT) {
            printf("  received: '%c' (0x%02x)\n", (char)c, c);
        }

        sleep_ms(1000);
    }
}
