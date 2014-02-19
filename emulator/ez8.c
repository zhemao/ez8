#include "ez8.h"
#include <stdio.h>

enum {
	REG_STATUS = 1
};

enum {
	STATUS_Z = 0,
	STATUS_C = 1,
	STATUS_BANK = 5,
	STATUS_GIE = 7
};

static uint8_t ez8_get(struct ez8_state *state, uint8_t addr)
{
	uint16_t actual_addr;
	uint8_t bank;

	if (addr < 4)
		return state->memory[addr];

	bank = (state->memory[REG_STATUS] >> STATUS_BANK) & 0x3;
	actual_addr = (bank << 8) | addr;

	return state->memory[actual_addr];
}

static void ez8_set(struct ez8_state *state, uint8_t addr, uint8_t val)
{
	uint16_t actual_addr;
	uint8_t bank;

	if (addr < 4) {
		state->memory[addr] = val;
		return;
	}

	bank = (state->memory[REG_STATUS] >> STATUS_BANK) & 0x3;
	actual_addr = (bank << 8) | addr;

	state->memory[actual_addr] = val;
}

static inline uint8_t
ez8_shift(uint8_t arg, uint8_t accum, uint16_t selector)
{
	if ((selector & 0x4) == 0)
		return accum << arg;

	if ((selector & 0x2) == 0)
		return accum >> arg;

	uint8_t topbits = ((1 << arg) - 1) << (8 - arg);
	return topbits | (accum >> arg);
}

static inline uint16_t
ez8_addsub(uint8_t arg, uint8_t accum, uint16_t selector, uint8_t status)
{
	uint8_t c = (status >> REG_STATUS) & 1;

	if ((selector & 0x4) != 0)
		return accum - arg;

	if ((selector & 0x2) == 0)
		return accum + arg;

	return accum + arg + c;
}

static inline uint8_t
ez8_bitwise(uint8_t arg, uint8_t accum, uint16_t selector)
{
	if ((selector & 0x4) != 0)
		return arg ^ accum;
	if ((selector & 0x2) == 0)
		return arg & accum;
	return arg | accum;
}

static void ez8_simple_instruction(struct ez8_state *state, uint16_t instr)
{
	uint16_t opcode, operand, selector, direction;
	uint8_t arg, accum, result, status, carry;

	opcode = (instr >> 12) & 0xf;
	operand = (instr >> 4) & 0xff;
	selector = (instr >> 1) & 0x7;
	direction = instr & 0x1;

	status = ez8_get(state, REG_STATUS);

	if (opcode < 4) {
		arg = ez8_get(state, operand);
	} else {
		arg = operand;
	}
	accum = state->accum;

	switch (opcode & 0x3) {
	case 0x0:
		result = (direction) ? accum : arg;
		break;
	case 0x1:
		result = ez8_shift(arg, accum, selector);
		break;
	case 0x2: {
		uint16_t big_result = ez8_addsub(arg, accum, selector, status);
		result = big_result & 0xff;
		carry = (big_result >> 8) & 0x1;
		break;
	}
	default:
		result = ez8_bitwise(arg, accum, selector);
		break;
	}

	if (operand != REG_STATUS || !direction) {
		if (result == 0)
			status |= (1 << STATUS_Z);
		else
			status &= ~(1 << STATUS_Z);

		if ((opcode & 0x3) == 0x2) {
			if (carry)
				status |= (1 << STATUS_C);
			else
				status &= ~(1 << STATUS_C);
		}
	}

	if (operand != REG_STATUS || !direction)
		ez8_set(state, REG_STATUS, status);

	if (direction)
		ez8_set(state, operand, result);
	else
		state->accum = result;
	state->pc++;
}

static inline int ez8_stack_full(struct ez8_state *state)
{
	return state->tos == EZ8_STACK_SIZE - 1;
}

static inline int ez8_stack_empty(struct ez8_state *state)
{
	return state->tos == -1;
}

static inline uint16_t ez8_stack_pop(struct ez8_state *state)
{
	uint16_t value = state->stack[state->tos];
	state->tos--;
	return value;
}

static inline void ez8_stack_push(struct ez8_state *state, uint16_t value)
{
	state->tos++;
	state->stack[state->tos] = value;
}

static int ez8_jump_instruction(struct ez8_state *state, uint16_t instr)
{
	uint16_t opcode = (instr >> 12) & 0xf;
	uint16_t addr = instr & 0xfff;

	if (opcode == 9) {
		if (ez8_stack_full(state))
			return -1;
		ez8_stack_push(state, state->pc);
	}

	state->pc = addr;

	return 0;
}

static int ez8_skip_instruction(struct ez8_state *state, uint16_t instr)
{
	uint16_t opcode = (instr >> 12) & 0xf;
	uint16_t addr = (instr >> 4) & 0xff;
	uint16_t selector = (instr >> 1) & 0x7;
	uint16_t direction = instr & 0x1;
	int8_t value, skip;

	if (direction)
		value = ez8_get(state, addr);
	else
		value = state->accum;

	if (opcode == 10) {
		switch (selector & 0x6) {
		case 0: skip = (value == 0); break;
		case 2: skip = (value < 0); break;
		default: skip = (value > 0); break;
		}
		if (selector & 0x1)
			skip = !skip;
	} else if (opcode == 11)
		skip = (((value >> selector) & 0x1) == 1);
	else
		skip = (((value >> selector) & 0x1) == 0);

	if (skip)
		state->pc += 2;
	else
		state->pc++;

	return 0;
}

static int ez8_ret_instruction(struct ez8_state *state, uint16_t instr)
{
	uint16_t retint = (instr >> 11) & 0x1;

	if (ez8_stack_empty(state))
		return -1;

	state->pc = ez8_stack_pop(state);

	if (retint) {
		uint8_t status = ez8_get(state, REG_STATUS);
		status |= (1 << STATUS_GIE);
		ez8_set(state, REG_STATUS, status);
	}

	return 0;
}

static void ez8_clr_com_instruction(struct ez8_state *state, uint16_t instr)
{
	uint16_t addr = (instr >> 4) & 0xff;
	uint16_t selector = (instr >> 3) & 0x1;
	uint16_t direction = instr & 0x1;
	uint8_t value;

	if (direction) {
		if (selector)
			value = ~ez8_get(state, addr);
		else
			value = 0;
		ez8_set(state, addr, value);
	} else {
		if (selector)
			value = ~(state->accum);
		else
			value = 0;
		state->accum = value;
	}
	state->pc++;
}

static void ez8_indirect_instruction(struct ez8_state *state, uint16_t instr)
{
	uint16_t offset = (instr >> 4) & 0xff;
	uint16_t indir_addr = (instr >> 1) & 0x3;
	uint16_t direction = instr & 0x1;
	uint8_t addr = ez8_get(state, indir_addr + 4) + offset;

	if (direction)
		ez8_set(state, addr, state->accum);
	else
		state->accum = ez8_get(state, addr);
	state->pc++;
}

int ez8_step(struct ez8_state *state)
{
	uint16_t instr, opcode;

	instr = state->code[state->pc];
	opcode = (instr >> 12) & 0xf;

	if (opcode < 8) {
		ez8_simple_instruction(state, instr);
		return 0;
	}

	if (opcode < 10)
		return ez8_jump_instruction(state, instr);
	if (opcode < 13)
		return ez8_skip_instruction(state, instr);
	if (opcode == 13)
		return ez8_ret_instruction(state, instr);
	if (opcode == 14) {
		ez8_indirect_instruction(state, instr);
		return 0;
	}
	if (opcode == 15) {
		ez8_clr_com_instruction(state, instr);
		return 0;
	}

	return 0;
}

int ez8_execute(struct ez8_state *state)
{
	int i;
	while (ez8_step(state) == 0) {
		if (state->pc >= state->code_len) {
			printf("PC at invalid address\n");
			return -1;
		}
		printf("pc: %d, a: %d, tos: %d\n",
				state->pc, state->accum, state->tos);
		for (i = 0; i < EZ8_MEM_SIZE; i++) {
			if (state->memory[i] != 0)
				printf("0x%x -> %d, ", i, state->memory[i]);
		}
		printf("\n");
	}

	return state->accum;
}
