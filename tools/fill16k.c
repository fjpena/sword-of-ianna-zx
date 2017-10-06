#include <stdio.h>
#include <stdlib.h>

// Tiny simple utility to expand a ROM file up to 16 KB
//
// Syntax: fill16k.exe <bin file> <rom file> 
//
typedef unsigned short uint16;
typedef unsigned char uchar;



int main(int argc, char **argv)
{
	FILE *in, *out;
	unsigned char dummyb;
	unsigned int counter;

	if (argc != 3)
	{
		printf("Syntax: fill16k.exe <bin file> <rom file>\n");
		return(1);				
	}

	in=fopen(argv[1],"rb");
	if (!in)
	{
		printf("Error opening input file %s\n",argv[1]);
		return(1);
	}

	out=fopen(argv[2],"wb");
	if (!out)
	{
		printf("Error opening output file %s\n",argv[2]);
		return(1);
	}

	counter=0;	
	while(!feof(in))
	{
		dummyb=fgetc(in);
		if(!feof(in)) 
		{
			fputc(dummyb,out);
			counter++;
		}
	}
	while(counter<16384)
	{
			fputc(0,out);
			counter++;		
	}
	fclose(in);
	fclose(out);
	return(0);
}