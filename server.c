#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>

#define SIZE 8192
// The code from the reference links mentioned in the document is used as a template.
// This receives the textfile
// Usage: ./server reno

int main(int argc, char * argv[])
{
  struct sockaddr_in sin; 
  char *TCP_variant;
  int addr_len;
  int s, new_s, len;
  struct sockaddr_in server_addr, new_addr;
  int SERVER_PORT;

  if (argc==3) {
    TCP_variant = argv[1];
    SERVER_PORT = atoi(argv[2]);
  }
  else {
    fprintf(stderr, "usage: simplex-talk TCP_variant PORT\n");
    exit(1);
  }

  /* build address data structure */
  server_addr.sin_family = AF_INET;
  server_addr.sin_addr.s_addr = INADDR_ANY;
  server_addr.sin_port = htons(SERVER_PORT);

  /* setup passive open */
  if ((s = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
    perror("simplex-talk: socket");
    exit(1);
  }
  else
    printf("Socket created.\n");

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
  printf("Server is using TCP %s.\n", TCP_variant);

  if ((bind(s, (struct sockaddr *)&server_addr, sizeof(server_addr))) < 0) {
    perror("simplex-talk: bind");
    exit(1);
  }
  else
    printf("Socket bind success.\n");
  
  if(listen(s, 10) == 0)
    printf("Listening....\n");
  else
  { 
    perror("Error in listening");
    exit(1);
  }

  socklen_t addr_size = sizeof(new_addr);
  new_s = accept(s, (struct sockaddr*)&new_addr, &addr_size);
  int read_return = 0, size = 0;
  char buffer[SIZE];
  int filefd = open("recv.txt",
                O_WRONLY | O_CREAT | O_TRUNC,
                S_IRUSR | S_IWUSR);
  // FILE* filefd = fopen("recv.txt", "w");
  if (filefd == -1) {
      perror("open");
      exit(EXIT_FAILURE);
  }
  bzero(buffer, SIZE);
  do {
      read_return = read(new_s, buffer, SIZE);
      if (read_return == -1) {
          perror("read");
          exit(EXIT_FAILURE);
      }
      if (read_return == 0) break;
      if (write(filefd, buffer, read_return) == -1) {
          perror("write");
          exit(EXIT_FAILURE);
      }
      bzero(buffer, SIZE);
      size+= read_return;
  } while (read_return > 0);
  
  printf("@%i\n", size);
  printf("Data written in the file successfully.\n");

  close(filefd);
  close(new_s);
  close(s);
  return 0;
}