#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <string.h>
#include "ez8.h"

int getfilesize(FILE *file)
{
	struct stat st;
	int ret;

	ret = fstat(fileno(file), &st);
	if (ret < 0)
		return ret;

	return st.st_size;
}

uint16_t *read_code(FILE *file, int *code_len)
{
	int size, nmemb;
	uint16_t *code;
	int i;

	size = getfilesize(file);
	if (size < 0)
		return NULL;
	nmemb = size / 2;

	code = malloc(size);
	if (code == NULL)
		return NULL;

	if (fread(code, 2, nmemb, file) != nmemb)
		return NULL;

	for (i = 0; i < nmemb; i++)
		code[i] = ntohs(code[i]);
	*code_len = nmemb;
	return code;
}

int main(int argc, char *argv[])
{
	FILE *input;
	uint16_t *code;
	int code_len, emu_ret;
	struct ez8_state state;

	if (argc < 2) {
		printf("Usage: %s code.bin\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	input = fopen(argv[1], "r");
	if (input == NULL) {
		perror("fopen");
		exit(EXIT_FAILURE);
	}

	code = read_code(input, &code_len);
	if (code == NULL) {
		fclose(input);
		perror("read_code");
		exit(EXIT_FAILURE);
	}

	state.code = code;
	state.code_len = code_len;
	state.pc = 0;
	state.accum = 0;
	state.tos = -1;
	memset(state.memory, 0, EZ8_MEM_SIZE);

	emu_ret = ez8_execute(&state);
	if (emu_ret) {
		printf("Program exited with error code %d\n", emu_ret);
	} else {
		printf("Program exited successfully\n");
	}

	return emu_ret;
}
