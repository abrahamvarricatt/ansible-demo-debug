
.. code::

                 _____             _    _    ____     _____
         /\     |  __ \           | |  | |  / __ \   / ____|
        /  \    | |  | |  ______  | |__| | | |  | | | |
       / /\ \   | |  | | |______| |  __  | | |  | | | |
      / ____ \  | |__| |          | |  | | | |__| | | |____
     /_/    \_\ |_____/           |_|  |_|  \____/   \_____|


**************************
What is an ad-hoc command?
**************************

An ad-hoc command is something that you might type in to do something really quick, but do not want to save for later.
It's unlikely that you'll use ad-hoc commands for regular orchestration, but they are helpful when you want to get
a quick status update or to push out a minor change in your infrastructure.

In ansible terminology, the commands that it runs on remote hosts are called modules. Ansible ships with a large
number of modules which can do things like control system resources (services, packages, files ...etc), handle
executing system commands ... etc. If you can't find a module which does what you want - feel free to build your own!
(Creating custom modules is outside the scope of this workshop - they are in essence Python scripts)

We'll re-use the existing workspace from segment-01.


Ping module
===========

Let us revisit the output from our earlier ping command,

.. code:: bash

    $ ansible all -i inventory/vagrant.ini -m ping
    192.168.77.20 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    $

Notice the word ``SUCCESS`` - this indicates that our command executed successfully. The module returned a dictionary.
One of the keys in this dictionary is called ``changed`` and it's value is ``false``. This indicated that the state
of the target host did not change. This is also indicated by the color of our response - green.


Ansible is idempotent
=====================

You might hear this word associated with configuration management. For details, you can look up the Wikipedia entry,
but for our purposes, it simply means that when running an ansible module a change will NOT be made to the target host
unless it needs to be made. This is very VERY important - to the point that ansible color-codes its response to
indicate change status. Let's try to demonstrate this with our next module,


Yum module
==========

Let's try to install the NTP utility on our target host. NTP (Network Time Protocol) is used to help synchronize
multiple systems against the same clock. Try running (be patient as it runs),

.. code:: bash

    $ ansible all -i inventory/vagrant.ini -m yum -a "name=ntp state=present"
    192.168.77.20 | FAILED! => {
        "changed": true,
        "failed": true,
        "msg": "You need to be root to perform this command.\n",
        "rc": 1,
        "results": [
            "Loaded plugins: fastestmirror\n"
        ]
    }

This time we specify the yum module by passing ``-m yum`` as an argument to ansible. The module can accept arguments,
which we pass in with the following ``-a "name=ntp state=present"``. What this means, is that we want the package
named ``ntp`` to be available on our target system.

Unfortunately, it would appear that the command failed - even the output color red highlights the fact! The ``msg``
value explains why. It seems that ansible did not have sufficient permission to execute the command. This is because
when ansible connects to our target system, it does so using the ``vagrant`` user account. This user cannot directly
install packages on the system, but can do so using ``sudo``. Let's modify our ad-hoc command to indicate this,

.. code:: bash

    $ ansible all -i inventory/vagrant.ini -m yum -a "name=ntp state=present" --sudo
    192.168.77.20 | SUCCESS => {
        "changed": true,
        "msg": "<TOO LONG OUTPUT REMOVED>",
        "rc": 0,
        "results": [
            "<TOO LONG OUTPUT REMOVED> \n\nComplete!\n"
        ]
    }

And it works! Notice that the ``changed`` value is marked as ``true`` and that the color of the command is yellow.
This indicates that the state of our target system was modified. Try running the command again,

.. code:: bash

    $ ansible all -i inventory/vagrant.ini -m yum -a "name=ntp state=present" --sudo
    192.168.77.20 | SUCCESS => {
        "changed": false,
        "msg": "",
        "rc": 0,
        "results": [
            "ntp-4.2.6p5-22.el7.centos.2.x86_64 providing ntp is already installed"
        ]
    }

Notice that nothing happened. The state of the target system did not change. This is what we mean by ansible being
idempotent. If it isn't necessary to perform an action - it isn't needlessly done. Compare this with writing a shell
script to perform the same action - it would be a magnitude more difficult to write and maintain!


Copy module
===========

For our next demonstration, we'll try to deploy a configuration file to our remote host. To do this, we first need
to create the file. Please create a folder called ``files`` in your workspace and create a file called ``ntp.conf``
with the following contents inside it,

.. code:: bash

    $ mkdir files
    $ cat files/ntp.conf
    driftfile /var/lib/ntp/drift
    restrict default nomodify notrap nopeer noquery
    restrict 127.0.0.1
    restrict ::1
    server 0.centos.pool.ntp.org iburst
    server 1.centos.pool.ntp.org iburst
    server 2.centos.pool.ntp.org iburst
    server 3.centos.pool.ntp.org iburst
    includefile /etc/ntp/crypto/pw
    keys /etc/ntp/keys
    disable monitor
    $

To run the ansible copy command, execute the following from your ``workspace`` directory,

.. code:: bash

    $ ansible all -i inventory/vagrant.ini  -m copy -a "src=ntp.conf dest=/etc/ntp.conf mode=644 owner=root group=root" --sudo
    192.168.77.20 | SUCCESS => {
        "changed": true,
        "checksum": "ca3aa56e93f0c1a6ee41675ee458514e57c5bfb4",
        "dest": "/etc/ntp.conf",
        "gid": 0,
        "group": "root",
        "md5sum": "139b8d67ca092d49d53837a3ca6f1baf",
        "mode": "0644",
        "owner": "root",
        "secontext": "system_u:object_r:net_conf_t:s0",
        "size": 319,
        "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1473760694.88-262959736845194/source",
        "state": "file",
        "uid": 0
    }

The above command just copied the file ``ntp.conf`` from our local computer to the remote target host (in this case,
the vagrant virtual system). If only the filename is given as value to the ``src`` key, ansible will look for the file
within a folder called ``files`` on the local system. You can also specify absolute path-names. Try re-running the
command a few times. You'll notice that it doesn't do anything on the target host (thanks to ansible's idempotent
property!).


Service module
==============

Let's now try playing around with services - those background tasks which keep a system busy. ;)  Run the following
command,

.. code:: bash

    $ ansible all -i inventory/vagrant.ini  -m service -a "name=ntpd state=restarted" --sudo
    192.168.77.20 | SUCCESS => {
        "changed": true,
        "name": "ntpd",
        "state": "started"
    }

The above command will try to restart the ntpd service. Re-running the command results in the same output, since
that is what restarting is about. If you try setting it to a different state, you can see different behaviors when
repeatedly running the command. A command like this needs to be used with caution since, it potentially breaks
the idempotentic nature of ansible.


Shell module
============

This might well be one of the most dangerous ansible modules available, so please use it with caution. From the name
you should be able to guess that it's about running arbitary shell commands on the target host. Here's an example,

.. code:: bash

    $ ansible all -i inventory/vagrant.ini  -m shell -a "uptime"
    192.168.77.20 | SUCCESS | rc=0 >>
     10:19:02 up  3:28,  2 users,  load average: 0.00, 0.01, 0.05

    $



And with this, we've completed this segment. To recap; the following concepts have been covered,

- ad-hoc command concept
- indempotent concept
- ping module
- yum module
- copy module
- service module
- shell module


To continue please refer the file 03-playbooks/README.rst
