Tools required
==============

- vagrant >= 1.8.1    ( https://www.vagrantup.com/downloads.html )
- ansible >= 2.1.1.0  ( http://docs.ansible.com/ansible/intro_installation.html )
- virtualbox >= 5.0   ( https://www.virtualbox.org/wiki/Downloads )

Basic instructions
==================

To bring up the system run,

.. code:: shell

    $ vagrant up

Once the system is up, try to SSH into the box with,

.. code:: shell

    $ vagrant ssh
    ...
    $ exit

You can quit out of the SSH session with `exit` command and return to host system.


After bringing up the system, navigate to the 'provision' folder and run the following command,

.. code:: shell

    $ cd provision
    $ ansible-playbook site.yml -i inventories/vagrant


The system should come up now. You should be able to visit,

- http://192.168.77.10/            (will see an error page)
- http://192.168.77.10/admin/      (a login page)
- http://192.168.77.10/polls/      (a list with links)


To turn off the virtual environment you can run,

.. code:: shell

    $ vagrant halt

To remove/delete the virtual system from your box,

.. code:: shell

    $ vagrant destroy



Workshop Notes
==============

During the workshop, I expect the need to send code snippets to participants. For this purpose, I've created the following gitter chatroom,

https://gitter.im/bangpy-ansible-workshop/Lobby#

Gitter was chosen because they allow anyone to view the chatroom without needing to register. An added (and personal) benefit is that gitter supports IRC connections for registered users (like myself) which means I can use my usual IRC client to talk to everyone, instead of another app. 


