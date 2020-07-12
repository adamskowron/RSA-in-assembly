#include <stdio.h>
#include <stdlib.h> 

int main()
{
	
	FILE* f = fopen("test.zip", "wb");

	int h = 1024;

	char byte = 0xFF;
	for(int i = 0; i < h; i++)
	       fwrite(&byte, 1, 1, f);

	fclose(f);
       	
	return 0;
}
