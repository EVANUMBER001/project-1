#include "userprog/syscall.h"
#include "threads/interrupt.h"
#include "threads/thread.h"
#include "threads/vaddr.h"
#include "userprog/pagedir.h"
#include "userprog/process.h"
#include <stdio.h>
#include <syscall-nr.h>

static void syscall_handler (struct intr_frame *);
static void check_pointer_valid (const void *p);
static void check_buffer_valid (const void *p, size_t size);

void sys_exit (int retval);

void
syscall_init (void)
{
  intr_register_int (0x30, 3, INTR_ON, syscall_handler, "syscall");
}

void
sys_exit (int retval)
{
  struct process *pcb = thread_current ()->pcb;
  printf ("%s: exit(%d)\n", pcb->process_name, retval);
  process_exit ();
}

static void
check_pointer_valid (const void *p)
{
  if (p == NULL)
    {
      /* printf ("%s: invalid pointer(%p)\n",
              thread_current ()->pcb->process_name, p);
         intr_dump_frame (f);
      */
      sys_exit (-1);
      NOT_REACHED ();
    }

  if (!is_user_vaddr (p))
    {
      /*
        printf ("%s: pointer refers to kernel space(%p)\n",
                thread_current ()->pcb->process_name, p);
        intr_dump_frame (f);
      */
      sys_exit (-1);
      NOT_REACHED ();
    }

  if (pagedir_get_page (thread_current ()->pcb->pagedir, p) == NULL)
    {
      /*
        printf ("%s: address is not mapped(%p)\n",
                thread_current ()->pcb->process_name, p);
        intr_dump_frame (f);
      */
      sys_exit (-1);
      NOT_REACHED ();
    }
}

static void
check_buffer_valid (const void *p, size_t size)
{
  while (size-- != 0)
    {
      check_pointer_valid (p);
      p = (void *)((char *)p + 1);
    }
}

void syscall_write (struct intr_frame *f);

/* int write (int fd, const void *buffer, unsigned size) */
struct write_args
{
  int id;
  int fd;
  const void *buffer;
  unsigned size;
};

void
syscall_write (struct intr_frame *f)
{
  struct write_args *args = (struct write_args *)f->esp;

  check_buffer_valid (&args->fd, sizeof (int));
  check_buffer_valid (&args->size, sizeof (unsigned));
  check_buffer_valid (&args->buffer, sizeof (const void *));
  check_buffer_valid (args->buffer, args->size);

  if (args->fd == STDOUT_FILENO)
    {
      putbuf ((const char *)args->buffer, args->size);
      f->eax = args->size;
      return;
    }

  f->eax = -1;
}

static void
syscall_handler (struct intr_frame *f UNUSED)
{
  uint32_t *args = ((uint32_t *)f->esp);

  /*
   * The following print statement, if uncommented, will print out the syscall
   * number whenever a process enters a system call. You might find it useful
   * when debugging. It will cause tests to fail, however, so you should not
   * include it in your final submission.
   */

  /* printf("System call number: %d\n", args[0]); */

  if (args[0] == SYS_EXIT)
    {
      sys_exit(args[1]);
    }

  if (args[0] == SYS_WRITE)
    {
      syscall_write (f);
    }
}
