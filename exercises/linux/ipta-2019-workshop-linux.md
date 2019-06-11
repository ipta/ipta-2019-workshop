### Where on earth am I, and who am I? How do I move around.

Command | What it does
--------|-------------
pwd     | Print your Current Working Directory
ls      | List files and directories in your current directory
cd      | Change directory
echo $HOME    | an environment variable that contains the full path to your home 

The directory structure on a UNIX/Linux/etc machine starts at "/", which is the very top of the hierarchical filesystem.  The filesystem is laid out underneath that, with elements of the path separated by */*


**ls** lists the contents of a directory. It will display the files in the current working directory or the directory specified. What is listed is not everything that is there. It does not display files that begin with a dot ("."), called dot files. Using the -a option (all) will display them. Check the man pages for more options when listing files.

```
$ ls -l /etc
```

The change directory command will take you to the /tmp directory.
```
$ cd /tmp
```

This one will take you up one directory, in this case the root directory /, and then over to the var directory.
```
$ cd ../var
```

With no arguments, cd will take you back to your home directory.
```
$ cd
```


### Look at all this junk.  How much space is it taking up

Command | What it does
--------|-------------
ls -lh	| Gives a *long* directory listing and includes the file size in "Human Readable" format
du      | Shows file sizes  / totals / etc for files and directories
df      | Shows filesystem usage

If you do an **ls -lhrt** in your home directory you'll see something like this:

```
-rw-r--r--  1 jovyan root   90K Jun  5 19:51 MultiNest_v3.11.tar.gz
drwxr-xr-x  6 jovyan root  4.0K Jun  5 21:25 tempo_utils
drwxr-xr-x 24 jovyan root  4.0K Jun  5 21:25 dspsr
drwxr-xr-x 24 jovyan root  4.0K Jun  5 21:25 TempoNest
drwxr-xr-x 22 jovyan  1000 4.0K Jun  5 21:25 MultiNest_v3.11
drwxr-xr-x 12 jovyan root  4.0K Jun  5 21:25 psrfits_utils
drwxr-xr-x 26 jovyan users 4.0K Jun  5 21:25 PINT
drwxr-xr-x 20 jovyan users 4.0K Jun  5 21:25 piccard
drwxr-xr-x  4 jovyan users 4.0K Jun  5 21:25 PAL2-demo
drwxr-xr-x  8 jovyan users 4.0K Jun  5 21:25 NX01
drwxr-xr-x  2 jovyan users 4.0K Jun  5 21:25 libstempo-demo
drwxr-xr-x  4 jovyan users 4.0K Jun 11 18:29 work
drwxr-xr-x  2 jovyan users 4.0K Jun 11 18:29 bin
```

Here the **l** stands for "long", **h** means human readable file sizes (B,K,M,G,T) instead of bits, **r** means reverse order, **t** means creation time.  This is a useful way of finding out which files in a directory were created most recently.

**du** can tell you how much space files and directories are taking up.  I find it to be most useful in this particular way:

```
$ du -sh *
4.0K	bin
90M	dspsr
1.5M	libstempo-demo
2.5M	MultiNest_v3.11
92K	MultiNest_v3.11.tar.gz
31M	NX01
96K	PAL2-demo
35M	piccard
115M	PINT
12M	psrfits_utils
413M	TempoNest
332K	tempo_utils
175M	work

```
Where **s** is summary and **h** is human readable.

and **df -h**, which is useful especially on remote systems in that it tells you where different parts of the filesystem are mounted and what there total, used and available capacities are

```
jovyan@3681ed48b648:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
none            200G  102G   89G  54% /
tmpfs           7.8G     0  7.8G   0% /dev
tmpfs           7.8G     0  7.8G   0% /sys/fs/cgroup
/dev/nvme0n1p3  200G  102G   89G  54% /etc/hosts
shm              64M     0   64M   0% /dev/shm
tmpfs           7.8G     0  7.8G   0% /sys/firmware

```

### What is my environment like?

This is an interesting question!  When you're interacting with a system the window that you're typing in is the "terminal", and the "shell" interprets the input and output that happens inside the shell. 

One way that you can find out what shell you are using is:

```
$ echo $SHELL 
```

On a modern system, in all likelihood it will be /bin/bash.  For more than you ever wanted to know about the history of UNIX shells see [this article](https://www.ibm.com/developerworks/library/l-linux-shells/index.html)

If you have been doing this for a long time, or if you are strongly influenced by your advisor then you may be using some form of csh / tcsh.


### Wait, what was that $SHELL thing we just did?

Glad you asked!  The **echo** command is one of the standard tools that is available on all Linux systems, and **$SHELL** was presented as an argument to that command.  It's a simple way to check the value of environment variables.  To see *all* of the environment variables available and their current values you you can do **env**.  Many of the astronomy software packages use environment variables to indicate where configuration files / plugins / etc live.  In the docker environment some that may be familiar to you are already set (see **echo $TEMPO**, **echo $PRESTO**, etc. 

To *set* the value of an environment variable, you use **export** (bash) or **set** (csh).  As we are using BASH in the docker container, try setting a new environment variable this way:

```
$ export NEAT=1
$ echo $NEAT
  1
```
the equivalent in CSH would be

```
$ set NEAT 1
$ echo $NEAT
 1
```

### Special Environment Variables

The Environment Variable that you have most likely come into contact with most is the PATH.  These are the  filesystem paths that shell will use to search for a program that you ask it to run.  Find out what your current path is

```
$ echo $PATH
  /usr/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin
```

Many people like to create a directory and add it to there path where they can keep scripts, or other programs. Let's create the directory ~/bin and add it to our path


### Doing things with files

Command | What it does
--------|-------------
touch   | creates an empty file.
mkdir   | creates an empty directory.
chmod   | changes file permissions
chown   | changes file ownership
chgrp   | changes file group

```
$ mkdir ~/bin
$ export PATH=${PATH}:~/bin
$ echo $PATH
  /usr/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin:~/bin
```

We have just created ~/bin and added it to the end of our path (**~/**  is shorthand for your home directory ). Now if we add an executable there we can use **which** to see it.

```
$ touch ~/bin/test
$ chmod +x ~/bin/test
$ which test
  /usr/bin/test
```
Wait just a minute! Where's my test? That is a *good question*!  You see, we put~/bin at the end of the path, not the beginning.  The shell will try and use the *first* instance of an executable that it finds.  To see all of the executables named "test" in your path do:

```
$ which -a test
```

Now, let's look at the permissions on the file
 
```
$ ls -lah ~/bin/test
  -rwxr-xr-x 1 jovyan users 0 Jun 11 18:23 test
```

ls will show you the permissions, file size and the last date the file was updated at.  The first grouping shows read/write/execute permissions for owner/group/world.  Traditionally we updated the permissions using #s, with these corresponding values:

0 == --- == no access
1 == --x == execute
2 == -w- == write
3 == -wx == write / execute
4 == r-- == read
5 == r-x == read / execute
6 == rw- == read / write
7 == rwx == read / write / execute

However, it is much easeir these days and you can reference u(user), g(group), o(other), a(all) and changes permissions like this:

```
$ chmod a+rwx ~/bin/test
$ ls -lah ~/bin/test
-rwxrwxrwx 1 jovyan users 0 Jun 11 18:29 test

```

You can also change the owner/group of a file, perhaps to make it accessible to a specific group.  You can find out what groups you belong to with **id -a**

```
$ id -a
  uid=1000(jovyan) gid=100(users) groups=100(users)
```

You can only change group ownership to groups of which you are a member.  As such, this isn't very exciting for the jovyan user.


### Making changes permanent

Say that you've decided that you'd like to permanently add ~/bin to your path.  To do that, you'll need to edit a hidden file in your home directory called ~/.bashrc. Each time that you log in this file is called, and its contents are run. 

You'll need to use an editor!  Although it can be painful, a universally available editor on nearly all UNIX systems is vi.  

To open your ~/.bashrc with vi you would do

```
$nano ~/.bashrc
```

Navigate to the end of the end of the file, hit enter and add

```
export PATH=~/bin:${PATH}
```
to the end of the file. To write and quit first type **Ctrl** and then **o**.  Congratulations! You've sucessfully edited your first file with nano. To exit, type **Ctrl** and then **x**  

###  Redirection, and pipes!

Redirecting output from one program to another can be a useful thing!  

Use the list command and > to redirect your output to a file named mylist.
```
$ ls -l /etc > mylist
```

There are three methods for viewing a file from the command prompt: cat, more and less

cat shows the contents of the entire file at the terminal, and scrolls automatically.
```
$ cat mylist
```

more shows the contents of the file, pausing when it fills the screen. Use the spacebar to advance one page at a time
```
$ more mylist
```

less also shows the contents of the file, pausing when it fills the screen. Use the spacebar to advance one page at a time, or use the arrow keys to scroll one line at a time (q to quit). "g" and "G" will take you to the beginning and end, respectively. less also provides capabilities for searching within a file by typing "/" and the word or characters you are searching for. This will take the file to the position of the first match for the word. Move between matches by using "n" and "?" keys.
```
$ less mylist
```

Try the following commands to become more familiar with redirection techniques.

The three lines below set up a redirection of standard output (from the concatenation command) to enter (from standard input) the famous phrase from Lincoln's Gettysburg address into a file called "lincoln.txt". The input to the cat command is ended with Control-D (^d). If you already have a file by this name, please choose another name.
```
$ cat > lincoln.txt
Four score and seven years ago
^d [Control-D]
```

These three lines append new text to the previously created file.
```
$ cat >> lincoln.txt 
our fathers brought forth on this continent a new nation 
^d
```

The next four commands demonstrate how to redirect input to a command (in this case, a script file that you create), that only reads from standard in. They create a script file called "tryme.sh" that contains the cat command. The way the cat command is used here, (with no arguments), forces it to read from standard input.
```
$ cat > tryme.sh 
#!/bin/sh 
cat 
^d [Control-D] 
```
The #! at the beginning of the script is called a shebang and in this case indicates which interpeter to use (/bin/sh is a special sort of file, called a symlink, which in this case points at the default shell interpreter, often /bin/bash; you can see where it points by typing ls -l /bin/sh).

As we want a script to be executed, we need to set the x permission for the file:
```
$ chmod u+x tryme.sh
```

The following line redirects standard input to the script file, resulting in the text of the file "lincoln.txt" being sent to standard out; tryme.sh simply executes cat in the bash shell (as specified by the #!/bin/bash). If you omit the redirection character (<), the script will try to read from standard in; this is the only way this script will display the contents of a file.
```
$ tryme.sh < lincoln.txt
```
### Pipes


Similar to redirection, pipes send the output of one command to the input of another, thereby chaining simple commands together to perform more complex processing than a single command can do. Most UNIX/Linux commands will read from standard in and write to standard out instead of only using a file. Try these examples.

The ls command's output is piped to the input of the sort command, which does a reverse sort and displays the output.
```
$ ls | sort -r
```

Here the pipe has the line count command (wc -l, described later in this exercise) read its input from the ls command's output. The result is the number of files in the directory.

```
$ ls | wc -l
```

### Searching

Finding files on the system and finding a particular text string within a file are very useful. Try these examples:

Find starts searching in /usr/lib, looking for files named libmenu.so, and whenever it finds one, prints its full path. The find command is useful for finding where missing libraries are located, so the path may be added to the LD_LIBRARY_PATH environment variable.

```
$ find /usr/lib -name libmenu.so -print
```

The global regular expression print (grep) command searches for patterns and prints matching lines. Here, it looks for "score" in the file lincoln.txt, created earlier.
```
$ grep score lincoln.txt
```

Here, grep searches input from ps -ef (which outputs all processes in full format), and prints out a list of csh users.

```
$ ps -ef | grep csh
```

###Sorting
The Linux sort command sorts the content of a file or any STDIN, and prints the sorted list to the screen.
```
$ cat temp.txt 
cherry
apple
x-ray
clock
orange
bananna

$ sort temp.txt
apple
bananna
cherry
clock
orange
x-ray
```
To see sorted list in reverse order, use the -r option.
```
$ sort -r temp.txt 
x-ray
orange
clock
cherry
bananna
apple
```
sort -n will sort the output numerically rather than alphabetically.

###Word and Line Count

The wc command reads either STDIN or a list of files and generates
1) numbers of lines
2) numbers of words
3) numbers of bytes.
Using the previous example:

```
$ cat temp.txt 
cherry
apple
x-ray
clock
orange
bananna
$ wc temp.txt 
 6  6 40 temp.txt
```
There are 6 lines, 6 words, and 40 bytes (or characters) in the file temp.txt.

You can also use the following options:

    Line count: -l
    Word count: -w
    Byte count: -c

```
$ wc -l temp.txt
6 temp.txt

$ wc -w temp.txt
6 temp.txt

$ wc -c temp.txt
40 temp.txt
```

###Installing packages

This docker image is using ubuntu, and ubutu uses something called "apt" to install packages.  I have neglected to install any advanced text editors or pdf viewers in the docker image, so you may want to install them yourself.  To do this, you'll need to connect to your container as root. So, in a new terminal window do 
```
docker exec -it --user root ipta /bin/bash
```
and then you can do 
```
apt update
apt search editor
```
which should output a long list of available packages.  You might want gedit or mousepad later in the week, and possibly evince if you need to view a pdf inside your container.  So do
```
apt install gedit evince 
```
or if you have a favorite non-graphical editor
```
apt install vim 
apt install emacs
```
