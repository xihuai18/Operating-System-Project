# Operating-System-Project

## Supported Functions(up to 1th July)
- Support command line, a simple shell.
- Support six-status(origin, ready, running, blocked, suspend, exit) process model.
- Support sub-thread mechanism.
- Support dynamic memory management and heap memory allocation.
- Support file system.
- Support virtual file system.
- Support semaphore mechanism.
- Support delay mechanism.
- support multiple terminals.

## commands
*              ls : list the information of the folders and files inside 
                     the current work path in the below format:
              name    size    loaded memory address    type
                                       (lma)   (E:executable, F:folder, D: document)
*            date : show the current time of the system.
*          reboot : reboot the computer.
*            exit : shutdown the computer immediately.
*           clear : clear the terminal.
*             man : show this help file.
*              ps : show the processes.
*       kill [Id] : kill a process with specified Id.
*       rm [name] : remove a file.
*     type [name] : show the contents of a file.
*             run : following by a list of programs, seperated by "enter".
*       susp [id] : suspend a process 
*       acti [id] : activate a process 
* cp [sour] [des] : cp files
*    touch [name] : create files
*   use "./" and the program following without space to run the program.

## Demostrations
Demo 1:

![Six-status model](/demos/six-status.gif)


Demo 2:

![Sub-thread and heap memory allocation mechanism](/demos/subThreads.gif)

Demo 3:

![File system demo 1](/demos/demo-create-and-delete.gif)

![File system demo 2](/demos/demo-cp.gif)

Demo 4:

![Multiple Terminal](/demos/demo.gif)

