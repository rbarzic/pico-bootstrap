#include "pico/stdlib.h"
#include "FreeRTOS.h"
#include "task.h"

static void led_task(void *) {
    const uint LED_PIN = 25;
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    while (true) {
        gpio_put(LED_PIN, 1);
        vTaskDelay(pdMS_TO_TICKS(500));
        gpio_put(LED_PIN, 0);
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

int main() {
    xTaskCreate(led_task, "LED", 256, nullptr, 1, nullptr);
    vTaskStartScheduler();

    // unreachable
    while (true) {}
}
