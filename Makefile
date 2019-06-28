program: cuda.cu
	nvcc -O2 -arch=sm_20 -o CudaProgram cuda.cu