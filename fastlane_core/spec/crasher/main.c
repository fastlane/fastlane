#include<stdio.h>
#include<signal.h>
#include<unistd.h> 
#include<stdlib.h>
int main()
{
    sigset_t act;
    sigemptyset(&act);
    sigfillset(&act);
    sigprocmask(SIG_UNBLOCK,&act,NULL);
    abort();
}
