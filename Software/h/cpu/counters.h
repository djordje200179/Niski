#pragma once

unsigned long long get_cpu_cycles();

inline static unsigned long long get_cpu_micros() {
    return get_cpu_cycles() / 50;
}

inline static unsigned long long get_cpu_millis() {
    return get_cpu_cycles() / 50000;
}

unsigned long long get_cpu_seconds();

unsigned long long get_cpu_inst_count();