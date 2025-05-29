#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
//#define DEBUG_LOG(msg,...)
#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;

    struct thread_data* thread_func_args = (struct thread_data *) thread_param;

    if (thread_func_args == NULL)
    {
        ERROR_LOG("Param NULL ERROR\n");
        return NULL;
    }
    
    if (thread_func_args->waitToLockMs > 0)
    {
        DEBUG_LOG("Thread %lu waiting before lock %d\n", pthread_self(), thread_func_args->waitToLockMs);
        usleep(thread_func_args->waitToLockMs*1000);
        
    }

    if (pthread_mutex_lock(thread_func_args->mutex) != 0)
    {
        ERROR_LOG("Cant Lock mutex\n");
        thread_func_args->thread_complete_success = false;
        return thread_func_args;
    }
    
    if (thread_func_args->waitToReleaseMs > 0)
    {
        DEBUG_LOG("Thread %lu waiting before release %d\n", pthread_self(), thread_func_args->waitToLockMs);
        usleep(thread_func_args->waitToReleaseMs*1000);
    }

    if (pthread_mutex_unlock(thread_func_args->mutex) != 0)
    {
        ERROR_LOG("Cant Release mutex\n");
        thread_func_args->thread_complete_success = false;
        return thread_func_args;
    }
    
    DEBUG_LOG("Thread %lu release %d mutex.\n", pthread_self(), thread_func_args->waitToLockMs);

    thread_func_args->thread_complete_success = true;

    
    return thread_func_args;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */


    struct thread_data *th = malloc(sizeof(struct thread_data));
    if (th  == NULL)
    {
        ERROR_LOG("Failed to allocate memory for thread data\n");
        return false;
    }
    
    // Setup Thread data
    th->mutex = mutex;
    th->waitToLockMs = wait_to_obtain_ms;
    th->waitToReleaseMs = wait_to_release_ms;
    th->thread_complete_success = false;

    int ret = pthread_create(thread, NULL, threadfunc, th);

    if (ret != 0)
    {
        // pThread create failed
        DEBUG_LOG("Failed to create thread: %d\n", ret);
        free(th);
        return false;
    }
    
    return true;
}

