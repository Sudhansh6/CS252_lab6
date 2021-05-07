#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <fcntl.h>
#include <netdb.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#define SIZE 8192
// The code from the reference links mentioned in the document is used as a template.
// This sends the textfile
// Usage: ./client localhost cubic or ./client 127.0.0.1 reno

int main(int argc, char * argv[])
{
  struct hostent *hp;
  struct sockaddr_in sin;
  char *host, *TCP_variant;
  int SERVER_PORT;
  int s;
  int len;

  if (argc==4) {
    host = argv[1];
    TCP_variant = argv[2];
    SERVER_PORT = atoi(argv[3]);
  }

  else {
    fprintf(stderr, "usage: simplex-talk host TCP_variant PORT\n");
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
      exit(1);
  }
  len = sizeof(TCP_variant);
  if (getsockopt(s, IPPROTO_TCP, TCP_CONGESTION, TCP_variant, &len) != 0)
  {
      perror("getsockopt");
      exit(1);
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

  int read_return = 0, size = 0;
  int filefd = open("send.txt", O_RDONLY);
  // FILE* filefd = fopen("send.txt", "r");
  char buffer[SIZE];
  struct timeval start, stop;
  gettimeofday(&start, NULL);
  while (1) {

    read_return = read(filefd, buffer, SIZE);
    if (read_return == 0)
        break;
    if (read_return == -1) {
        perror("read");
        exit(EXIT_FAILURE);
    }
    if (write(s, buffer, read_return) == -1) {
        perror("write");
        exit(EXIT_FAILURE);
    }
    size+= read_return;
  }
  // while(read_return = fread(buffer, SIZE, 1, filefd) != NULL) {
  //   if (send(s, buffer, SIZE, 0) == -1) {
  //     perror("Error in sending file.");
  //     exit(1);
  //   }
  //   size += SIZE;
  //   bzero(buffer, SIZE);
  // }
  gettimeofday(&stop, NULL);

  printf("# %ld %ld %ld %ld %i\n", start.tv_sec, start.tv_usec, stop.tv_sec, stop.tv_usec, size);
  printf("File data sent successfully.\n");

  printf("Closing the connection.\n");

  close(s);
  return 0;

}