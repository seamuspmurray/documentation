#include <stdio.h>
#include <sys/time.h>
#include <time.h>
#include <stdlib.h>
#include <stdint.h>

unsigned long get_rdtscp(int *chip, int *core);
static unsigned long long get_rdtsc();

int main() {
    char clocksource[4][15] = {"\0"};
    char initial_clocksource[15] = "\0";
    struct timeval mytime;
    struct timezone mytimezone;
    clock_t start, end;
    int x = 0;
    int y = 0;

    uint64_t starting_tsc = 0;
    uint64_t finishing_tsc = 0;
    uint64_t starting_tscp = 0;
    uint64_t finishing_tscp = 0;

    int my_chip = 0;
    int my_core = 3;
    int *chip = &my_chip;
    int *core = &my_core;

    FILE *get_clocksource = fopen("/sys/devices/system/clocksource/clocksource0/current_clocksource", "r");
    if (get_clocksource == NULL) {
        perror("Failed to open current_clocksource for reading");
        exit(1);
    }
    fscanf(get_clocksource, "%s", initial_clocksource);
    fclose(get_clocksource);
    printf("Initial ClockSource setting is: %s\n", initial_clocksource);

    FILE *current_clocksource = fopen("/sys/devices/system/clocksource/clocksource0/current_clocksource", "w");
    if (current_clocksource == NULL) {
        perror("Failed to open current_clocksource for writing");
        exit(1);
    }
    fclose(current_clocksource);

    FILE *available_clocksources = fopen("/sys/devices/system/clocksource/clocksource0/available_clocksource", "r");
    if (available_clocksources == NULL) {
        perror("Failed to open available_clocksource for reading");
        exit(1);
    } else {
        fscanf(available_clocksources, "%s %s %s %s %s", clocksource[0], clocksource[1], clocksource[2], clocksource[3], clocksource[4]);
        printf("Available ClockSources: %s %s %s %s %s\n", clocksource[0], clocksource[1], clocksource[2], clocksource[3], clocksource[4]);
    }
    fclose(available_clocksources);

    printf("+----------------------------------------------------------------------------------------------------------+\n");
    printf("|ClockSrc|Exec time | Start  | Finish  | RDSTC start    |  RDTSC finish  | RDTSCP start   | RDTSCP finish  |\n");
    printf("+--------+----------+--------+---------+----------------+----------------+----------------+----------------+\n");
    while (x < 4 && clocksource[x][0] != '\0') {
        FILE *current_clocksource = fopen("/sys/devices/system/clocksource/clocksource0/current_clocksource", "w");
        if (current_clocksource == NULL) {
            perror("Failed to open current_clocksource for writing");
            exit(1);
        }
        fprintf(current_clocksource, "%s", clocksource[x]);
        fclose(current_clocksource);

        y = 0;
        starting_tscp = get_rdtscp(chip, core);
        starting_tsc = get_rdtsc();
        start = clock();
        while (y < 1000000) {
            gettimeofday(&mytime, &mytimezone);
            y++;
        }
        end = clock();
        finishing_tsc = get_rdtsc();
        finishing_tscp = get_rdtscp(chip, core);
        printf("|%-7s | %-7f | %-6ld | %-7ld | %ld | %ld | %ld | %ld |\n", clocksource[x], ((double) (end - start)) / CLOCKS_PER_SEC, start, end, starting_tsc, finishing_tsc, starting_tscp, finishing_tscp);
        x++;
    }

    FILE *set_clocksource = fopen("/sys/devices/system/clocksource/clocksource0/current_clocksource", "w");
    if (set_clocksource == NULL) {
        perror("Failed to open current_clocksource for writing");
        exit(1);
    }
    fprintf(set_clocksource, "%s", initial_clocksource);
    fclose(set_clocksource);

    printf("+----------------------------------------------------------------------------------------------------------+\n");
    return 0;
}

static __inline__ unsigned long long get_rdtsc(void) {
    unsigned tsc_val_lo, tsc_val_hi;
    __asm__ __volatile__ ("rdtsc" : "=a"(tsc_val_lo), "=d"(tsc_val_hi));
    return ((unsigned long long) tsc_val_lo) | (((unsigned long long) tsc_val_hi) << 32);
}

unsigned long get_rdtscp(int *chip, int *core) {
    unsigned a, d, c;
    __asm__ volatile("rdtscp" : "=a" (a), "=d" (d), "=c" (c));
    *chip = (c & 0xFFF000) >> 12;
    *core = c & 0xFFF;
    return ((unsigned long) a) | (((unsigned long) d) << 32);
}

