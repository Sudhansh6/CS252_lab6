#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SERVER_PORT 8000
#define SIZE 512 // each char takes 4 bytes, we need 5000000 bytes -> 1250000 chars
// The code from the reference links mentioned in the document is used as a template.
// This sends the textfile
// Usage: ./client localhost cubic or ./client 127.0.0.1 reno
void send_file(FILE *fp, int s){
  int n;
  char data[SIZE] = {0};
  struct timeval start;
  gettimeofday(&start, NULL);
  while(fgets(data, SIZE, fp) != NULL) {
    if (send(s, data, sizeof(data), 0) == -1) {
      perror("Error in sending file.");
      exit(1);
    }
    bzero(data, SIZE);
  }
  printf("# %ld %ld.\n", start.tv_sec, start.tv_usec);
} 

int main(int argc, char * argv[])
{
  FILE *fp;
  char *filename = "input.txt";
  struct hostent *hp;
  struct sockaddr_in sin;
  char *host, *TCP_variant;
  int s;
  int len;

  if (argc==3) {
    host = argv[1];
    TCP_variant = argv[2];
  }
  else {
    fprintf(stderr, "usage: simplex-talk host TCP_variant\n");
    exit(1);
  }

  /* translate host name into peer's IP address */
  hp = gethostbyname(host);
  if (!hp) {
    fprintf(stderr, "simplex-talk: unknown host: %s\n", host);
    exit(1);
  }
  else
    printf("Host detected.\n");

  /* build address data structure */
  bzero((char *)&sin, sizeof(sin));
  sin.sin_family = AF_INET;
  bcopy(hp->h_addr, (char *)&sin.sin_addr, hp->h_length);
  sin.sin_port = htons(SERVER_PORT);

  /* active open */
  if ((s = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
    perror("simplex-talk: socket");
    exit(1);
  }
  else
    printf("Socket created.\n");

  // Set TCP protocol
  len = strlen(TCP_variant);
  if (setsockopt(s, IPPROTO_TCP, TCP_CONGESTION, TCP_variant, len) != 0)
  {
      perror("setsockopt");
      return -1;
  }
  len = sizeof(TCP_variant);
  if (getsockopt(s, IPPROTO_TCP, TCP_CONGESTION, TCP_variant, &len) != 0)
  {
      perror("getsockopt");
      return -1;
  }
  printf("Client is using TCP %s.\n", TCP_variant);

  if (connect(s, (struct sockaddr *)&sin, sizeof(sin)) < 0)
  {
    perror("simplex-talk: connect");
    close(s);
    exit(1);
  }
  else
    printf("Connection successful.\n");

  fp = fopen(filename, "r");
  if (fp == NULL) {
    perror("Error in reading file.");
    exit(1);
  }

  send_file(fp, s);
  printf("File data sent successfully.\n");

  printf("Closing the connection.\n");
  close(s);

  return 0;

}
