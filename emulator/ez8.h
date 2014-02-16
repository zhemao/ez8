#ifndef __EZ8_H__
#define __EZ8_H__

#include <stdint.h>

struct ez8_state {
	uint16_t *code;
	int code_len;
	uint16_t pc;
	uint8_t accum;
	uint8_t tos;

	uint16_t stack[16];
	uint8_t memory[1024];
};

int ez8_step(struct ez8_state *state);
int ez8_execute(struct ez8_state *state);

#endif
