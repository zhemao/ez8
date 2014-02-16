#include "ez8.h"

enum regmap {
	REG_STATUS = 1
};

enum status_bits {
	STATUS_Z = 0,
	STATUS_C = 1,
	STATUS_BANK = 5,
	STATUS_GIE = 7
};

static inline uint8_t ez8_get(struct ez8_state *state, uint8_t addr)
{
	uint16_t actual_addr;
	uint8_t bank;

	if (addr < 4)
		return state->memory[addr];

	bank = (state->memory[REG_STATUS] >> STATUS_BANK) & 0x3;
	actual_addr = (bank << 8) | addr;

	return state->memory[actual_addr];
}

static inline void ez8_set(struct ez8_state *state, uint8_t addr, uint8_t val)
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

	if (opcode < 8) {
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

	ez8_set(state, REG_STATUS, status);

	if (direction)
		ez8_set(state, operand, result);
	else
		state->accum = result;
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

	if (state->pc > state->code_len)
		return -1;

	return 0;
}

int ez8_execute(struct ez8_state *state)
{
	while (ez8_step(state) == 0);
	return state->accum;
}
