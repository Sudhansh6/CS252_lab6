#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>

// The buffer size
#define SIZE 8192
// The code from the reference links mentioned in the problem statement were used as a template.
// This receives the textfile
// Usage: ./server reno PORT

int main(int argc, char * argv[])
{
  // Variables to set up sockets
  struct sockaddr_in sin; 
  char *TCP_variant;
  int addr_len;
  int s, new_s, len;
  struct sockaddr_in server_addr, new_addr;
  int SERVER_PORT;

  //number of arguments must be 3
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

  //TCP Protocol here
  len = strlen(TCP_variant);
  if (setsockopt(s, IPPROTO_TCP, TCP_CONGESTION, TCP_variant, len) != 0)
  {
      perror("setsockopt");
      return -1;
  }
  // Verifying if the TCP protocol is correct
  len = sizeof(TCP_variant);
  if (getsockopt(s, IPPROTO_TCP, TCP_CONGESTION, TCP_variant, &len) != 0)
  {
      perror("getsockopt");
      return -1;
  }
  printf("Server is using TCP %s.\n", TCP_variant);

  //Checking if the socket has binded successfully
  if ((bind(s, (struct sockaddr *)&server_addr, sizeof(server_addr))) < 0) {
    perror("simplex-talk: bind");
    exit(1);
  }
  else
    printf("Socket bind success.\n");

  //Listening to the server
  if(listen(s, 10) == 0)
    printf("Listening....\n");
  else
  { 
    perror("Error in listening");
    exit(1);
  }

  // new_s accepts connection from the client
  socklen_t addr_size = sizeof(new_addr);
  new_s = accept(s, (struct sockaddr*)&new_addr, &addr_size);

  //writing content into recv.txt
  int read_return = 0, size = 0;
  // Create a buffer
  char buffer[SIZE];

  // open the recv.txt file to write
  int filefd = open("recv.txt",
                O_WRONLY | O_CREAT | O_TRUNC,
                S_IRUSR | S_IWUSR);
  if (filefd == -1) {
      perror("open");
      exit(EXIT_FAILURE);
  }
  bzero(buffer, SIZE);

  // Repeat until recv.txt is entirely RECEIVED
  do {
      // Read the conents of the client socket into the buffer
      read_return = read(new_s, buffer, SIZE);
      // exit if file is corrupt
      if (read_return == -1) {
          perror("read");
          exit(EXIT_FAILURE);
      }
      // Write the contents of the file into the buffer
      if (write(filefd, buffer, read_return) == -1) {
          perror("write");
          exit(EXIT_FAILURE);
      }
      // Empty the buffer after writing
      bzero(buffer, SIZE);
      // Count the number of bytes received
      size+= read_return;
  } while (read_return > 0);
  
  // Print the number of bytes received
  printf("@ %i\n", size);
  printf("Data written in the file successfully.\n");
  
  // Close the file pointer and socket after transmission
  close(filefd);
  close(new_s);
  return 0;
}