#ifndef __EZ8_H__
#define __EZ8_H__

#include <stdint.h>

#define EZ8_STACK_SIZE 16
#define EZ8_MEM_SIZE 1024

struct ez8_state {
	uint16_t *code;
	int code_len;
	uint16_t pc;
	uint8_t accum;
	uint8_t tos;

	uint16_t stack[EZ8_STACK_SIZE];
	uint8_t memory[EZ8_MEM_SIZE];
};

int ez8_step(struct ez8_state *state);
int ez8_execute(struct ez8_state *state);

#endif
