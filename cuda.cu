#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>
#include <cuda.h>
#include <time.h>


__global__
void findResult(char *inputFile, char* outputFile)
{
	int idx = (blockIdx.x * blockDim.x) + threadIdx.x;
	int n = 0;

	for (int i = (idx*100); i <= ((idx*100) + 99); i++) {
		
		if (*(inputFile + i) == ',') {
			*(outputFile + (4 * idx + n)) = *(inputFile + (i+1));
			n++;
		}
	}

}

int main(int argc, char** argv)
{
	clock_t time;
	FILE* f = fopen(argv[1], "r");
	char* inputFile_h = (char*)malloc(1550000 * sizeof(char));
	int i, j;
	i = 0;

	while ((j = fgetc(f)) != EOF) {
		*(inputFile_h + i) = (char)j;
		i++;
	}
	fclose(f);
	*(inputFile_h + i) = '\0';

	printf("serial(s) or parallel(p): \n");
	char choice;
	scanf("%c", &choice);

	char* outputFile_h = (char*)malloc(1000000 * sizeof(char));
	
	if (choice == 's') {
		int k = 0;
		i = 0;
		char ch;

		time = clock();

		while (*(inputFile_h + i) != '\0') {
			ch = (*(inputFile_h + i));
			if (ch == ',') {
				*(outputFile_h + k) = *(inputFile_h + (i + 1));
				k++;
			}
			i++;
		}
		*(outputFile_h + k) = '\0';
	}

	else if (choice == 'p') {
		char* inputFile_d = '\0';
		char* outputFile_d = '\0';

		size_t i_size = (strlen(inputFile_h)) * sizeof(char);
		size_t o_size = 1000000 * sizeof(char);

		time = clock();
		cudaMalloc((void**)&inputFile_d, i_size);
		cudaMalloc((void**)&outputFile_d, o_size);		

		cudaMemcpy(inputFile_d, inputFile_h, i_size, cudaMemcpyHostToDevice);

		findResult << < 15, 1024 >> > (inputFile_d, outputFile_d);
		
		cudaMemcpy(outputFile_h, outputFile_d, o_size, cudaMemcpyDeviceToHost);

	}
	cudaDeviceSynchronize();
	time = clock() - time;
	f = fopen("output.txt", "w");
	
	for (int i = 0; i < 61441; i++) {
		if (*(outputFile_h + i) != NULL) {
			fprintf(f, "%c", *(outputFile_h + i));
		}
		
	}
	fclose(f);
	printf("Time: %f second\n", ((float)time / CLOCKS_PER_SEC));

	system("PAUSE");
}