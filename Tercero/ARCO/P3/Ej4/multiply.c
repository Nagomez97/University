#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "arqo3.h"

void compute(tipo **matrix, tipo **res,int n);

int main(int argc, char *argv[]) {

	int n;
	tipo **m=NULL;
	tipo **res=NULL;
	struct timeval fin, ini;

	if( argc!=2 )
	{
		printf("Error: ./%s <matrix size>\n", argv[0]);
		return -1;
	}
	n=atoi(argv[1]);
	m=generateMatrix(n);
	if( !m )
	{
		return -1;
	}

	res=generateEmptyMatrix(n);
	if( !res )
	{
		return -1;
	}

	gettimeofday(&ini,NULL);

	/* Main computation */
	compute(m, res, n);
	/* End of computation */

	gettimeofday(&fin,NULL);
	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	printf("Completado\n");
	


	free(m);
	free(res);
	return 0;


}


void compute(tipo **matrix, tipo **res, int n)
{
	int i,j,k,suma;
	
	for(i=0;i<n;i++)
	{
		for(j=0;j<n;j++)
		{
			suma=0;
			for(k=0; k<n; k++){
				suma += matrix[i][k] * matrix[k][j];
			}
			res[i][j] = suma;
		}
	}
	return;
}