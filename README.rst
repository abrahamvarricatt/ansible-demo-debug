#######################
BangPy Ansible Workshop
#######################

+---------------------+----------------------------------------------------+
|  Date               |  17/September/2016                                 |
+---------------------+----------------------------------------------------+
|  Time               |  10 AM - 2 PM                                      |
+---------------------+----------------------------------------------------+
|  Venue              |  | Red Hat India Pvt Ltd.                          |
|                     |  | IBC Knowledge Park, 11th Floor                  |
|                     |  | Tower D, Bangalore - 560 029                    |
+---------------------+----------------------------------------------------+
|  Instructor         |  Abraham Varricatt                                 |
+---------------------+----------------------------------------------------+
|  Contact            |  | https://twitter.com/chronodekar                 |
|                     |  | https://www.linkedin.com/in/abrahamvarricatt    |
|                     |  | NOTE: Please mention this workshop to avoid     |
|                     |  |       being mistaken for spam                   |
+---------------------+----------------------------------------------------+
|  Chatroom           |   `Gitter chatroom for bangpy-ansible-workshop`_   |
|  (during workshop)  |                                                    |
+---------------------+----------------------------------------------------+

.. _Gitter chatroom for bangpy-ansible-workshop: https://gitter.im/bangpy-ansible-workshop/Lobby#

This repository was created to assist in conducting a workshop for the Bangalore Python User Group about Ansible. It is
distributed under the MIT License as mentioned at the end of this file.

************
Requirements
************

It is assumed that participants have access to a computer running a flavour of Linux OS with the following
tools installed,

- vagrant >= 1.8.1    ( https://www.vagrantup.com/downloads.html )
- ansible >= 2.1.1.0  ( http://docs.ansible.com/ansible/intro_installation.html )
- virtualbox >= 5.0   ( https://www.virtualbox.org/wiki/Downloads )

You can check the currently installed versions with the following commands,

.. code:: bash

    $ vboxmanage --version
    5.0.24_Ubuntur108355
    $ vagrant --version
    Vagrant 1.8.1
    $ ansible --version
    ansible 2.1.1.0
      config file = /etc/ansible/ansible.cfg
      configured module search path = Default w/o overrides
    $

NOTE: Beyond installing the above three tools, there is NO requirement to use the ``sudo`` command or run any of the
instructions as the root user on your host computer.

The documentation will assume that you have this repository cloned into a folder called bangpy-ansible-workshop by
running the following commands,

.. code:: bash

    $ cd ~
    $ git clone https://github.com/abrahamvarricatt/bangpy-ansible-workshop.git
    $ cd bangpy-ansible-workshop

If you are working with a different folder structure, please change the instructions accordingly.

************
Introduction
************

Welcome and thank you for coming! We'll be dividing the workshop into multiple segments. At the start of each segment
you will be asked to initialize a fresh vagrant-based working environment and to create an empty folder called
``workspace`` within which we'll be performing our exercises. This repository already contains a few sub-folders which
hold instructions for each segment as well as reference code.


Getting familiar with vagrant
=============================

To begin, let's bring up our first vagrant environment by running ``vagrant up`` (example below),

.. code:: bash

    $ cd ~/bangpy-ansible-workshop
    $ vagrant up

This will configure a CentOS 7 virtual system, in a private network with IP = 192.168.77.20

To verify that the system is running smoothly, we can check its status,

.. code:: bash

    $ vagrant status
    Current machine states:

    webapp                    running (virtualbox)

    The VM is running. To stop this VM, you can run `vagrant halt` to
    shut it down forcefully, or you can run `vagrant suspend` to simply
    suspend the virtual machine. In either case, to restart it again,
    simply run `vagrant up`.
    $

The above output shows the following information - name of the virtual system (webapp), its current status (running)
and finally what virtualization tool was used to bring it up (virtualbox).

Let's try logging into ``webapp`` by making use of vagrant's in-build SSH utility,

.. code:: bash

    $ vagrant ssh
    [vagrant@webapp ~]$ cat /etc/hostname
    webapp
    [vagrant@webapp ~]$ exit
    logout
    Connection to 127.0.0.1 closed.
    $

Next, lets again login via SSH, but without using vagrant's help - this should be identical to the way you connect to
a remote system. For these vagrant-based systems, the credentials are; username/password = vagrant/vagrant

.. code:: bash

    $ ssh vagrant@192.168.77.20
    The authenticity of host '192.168.77.20 (192.168.77.20)' can't be established.
    ECDSA key fingerprint is SHA256:qHi1r+H6N2WKPmF3Up0RlIeXt6E5b1oKqNpEFzyvflw.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '192.168.77.20' (ECDSA) to the list of known hosts.
    vagrant@192.168.77.20's password:
    Last login: Tue Sep 13 06:18:27 2016 from 10.0.2.2
    [vagrant@webapp ~]$ cat /etc/centos-release
    CentOS Linux release 7.2.1511 (Core)
    [vagrant@webapp ~]$ exit
    logout
    Connection to 192.168.77.20 closed.
    $

NOTE: We're using password-based authentication to keep things simple. The tools DO support other schemes as well.

Lets power-off the system with ``vagrant halt`` and check the status,

.. code:: bash

    $ vagrant halt
    ==> webapp: Attempting graceful shutdown of VM...
    $ vagrant status
    Current machine states:

    webapp                    poweroff (virtualbox)

    The VM is powered off. To restart the VM, simply run `vagrant up`
    $

Finally let's run ``vagrant destroy`` to destroy (and remove) the virtual system from our host.

.. code:: bash

    $ vagrant destroy
        webapp: Are you sure you want to destroy the 'webapp' VM? [y/N] y
    ==> webapp: Destroying VM and associated drives...
    $ vagrant status
    Current machine states:

    webapp                    not created (virtualbox)

    The environment has not yet been created. Run `vagrant up` to
    create the environment. If a machine is not created, only the
    default provider will be shown. So if a provider is not listed,
    then the machine is not created for that environment.
    $

Please take note that ``vagrant status`` marks the system as 'not created'. It's truly gone! :O


Preparing for segment - 01
==========================

We need the vagrant system to proceed, so please bring a new one back online. Once that's done, create an empty folder
called ``workspace`` and navigate to it.

.. code:: bash

    $ cd ~/bangpy-ansible-workshop
    $ vagrant up
    $ mkdir workspace
    $ cd workspace

To continue please refer the file 01-ansible-configs/README.rst

#######
License
#######

MIT License

Copyright (c) 2016 Abraham Varricatt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.




