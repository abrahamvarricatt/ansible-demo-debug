Tools required
==============

- vagrant >= 1.8.1    ( https://www.vagrantup.com/downloads.html )
- ansible >= 2.1.1.0  ( http://docs.ansible.com/ansible/intro_installation.html )
- virtualbox >= 5.0   ( https://www.virtualbox.org/wiki/Downloads )

Pre-requisites to install the tools
===================================

Prior to installation of the tools, check:

- Login id's $HOME has 'write' permissions for "other"
- Clone the git repo given in README.rst procedure

To bring up the system run this command from cloned repo dir,

.. code:: shell

    $ vagrant up

After bringing up the system, navigate to the 'provision' folder and run the following command,

.. code:: shell

    $ ansible-playbook site.yml -i inventories/vagrant


Wait for the system should come up; post completion of playbook, below links should work.

- http://192.168.77.10/            (will see an error page)
- http://192.168.77.10/admin/      (a login page)
- http://192.168.77.10/polls/      (a list with links)


