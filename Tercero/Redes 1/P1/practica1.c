#include <practica1.h>

int main(int argc, char** argv){
	if(argc == 1) return show_help();
	else if(argc == 2) return live_capture(argv[1]);
	else if(argc == 3) return pcap_analyze(argv[1], argv[2]);
	else return show_help();
	return EXIT_OK;
}