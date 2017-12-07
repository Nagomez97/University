// ----------- Arqo P4-----------------------
// pescalar_par2
//
#include <stdio.h>
#include <stdlib.h>
#include "arqo4.h"

int main(int argc, char* argv[])
{
	float *A=NULL, *B=NULL;
	long long k=0, size;
	struct timeval fin,ini;
	float sum=0;
	int thr;

	/*El tamaño por defecto es el tamaño definido en la macro M y el numero de threads T*/
	if(argc == 1){
		size = M;
		thr = T;
	}
	else if(argc != 3){
		printf("Vector size and number of threads are needed.\n");
		return -1;
	}
	else{
		size = atoll(argv[1]);
		thr = atoi(argv[2]);
	}
	
	A = generateVector(size);
	B = generateVector(size);
	if ( !A || !B )
	{
		printf("Error when allocationg matrix\n");
		freeVector(A);
		freeVector(B);
		return -1;
	}
	
	gettimeofday(&ini,NULL);
	/* Bloque de computo */
	sum = 0;
	omp_set_num_threads(thr);
	#pragma omp parallel for reduction(+:sum)
	for(k=0;k<size;k++)
	{	
		if(k==0)
		printf("Numero de threads: %d\n", omp_get_num_threads());
		sum = sum + A[k]*B[k];
	}
	/* Fin del computo */
	gettimeofday(&fin,NULL);

	printf("Resultado: %f\n",sum);
	printf("Tiempo: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	freeVector(A);
	freeVector(B);

	return 0;
}
