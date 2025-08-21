
#include <stdint.h>

#include "sdk_common.h"
#include "nrf_delay.h"
#include "nrf_gpio.h"

#include "nrf_log.h"
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"

#define DELAY_MS 500

#define GPIO_LED1 NRF_GPIO_PIN_MAP(0, 13)
#define GPIO_LED2 NRF_GPIO_PIN_MAP(0, 14)
#define GPIO_LED3 NRF_GPIO_PIN_MAP(0, 15)
#define GPIO_LED4 NRF_GPIO_PIN_MAP(0, 16)

static const uint8_t led_count = 4;
static const uint32_t leds[] = {GPIO_LED1, GPIO_LED2, GPIO_LED3, GPIO_LED4};

/**
 * @brief Initialize logging.
 */
void log_init(void) {
    ret_code_t err = NRF_LOG_INIT(NULL);
    APP_ERROR_CHECK(err);

    NRF_LOG_DEFAULT_BACKENDS_INIT();
}

/**
 * @brief Initialize LEDs.
 */
void led_init(void) {
    for (int i = 0; i < led_count; i++) {
        uint32_t led = leds[i];
        nrf_gpio_cfg_output(led);   /* Configure LED pin as output */
        nrf_gpio_pin_write(led, 1); /* Turn off LED */
    }
}

int main(void) {
    STATIC_ASSERT(ARRAY_SIZE(leds) == led_count);

    log_init();
    led_init();
    uint16_t cnt = 0;

    NRF_LOG_INFO("Blink example started");
    while (1) {
        for (int i = 0; i < led_count; i++) {
            nrf_gpio_pin_toggle(leds[i]);

            NRF_LOG_INFO("[%05d] LED%d toggled", cnt++, i + 1);
            NRF_LOG_FLUSH();

            nrf_delay_ms(DELAY_MS);
        }
    }
}
