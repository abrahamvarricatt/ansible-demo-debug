
.. code::

         _              _ _     _
        / \   _ __  ___(_) |__ | | ___
       / _ \ | '_ \/ __| | '_ \| |/ _ \
      / ___ \| | | \__ \ | |_) | |  __/
     /_/   \_\_| |_|___/_|_.__/|_|\___|


****************
What is Ansible?
****************

Ansible is an IT automation tool. It can configure systems, deploy software, and orchestrate more advanced IT tasks
such as continuous deployments or zero downtime rolling updates. It manages machines in an agent-less manner.

TODO: insert comment of what happens in this workshop


Configuring Ansible
===================

Certain settings in Ansible are adjustable via a configuration file. The default configuration should be sufficient
for most users, but for the sake of familiarization, we'll create a new one ourselves. Please create a file called
``ansible.cfg`` in your workspace directory with the following contents,

.. code:: bash

    $ cat ansible.cfg
    [defaults]

    # log file location
    log_path=./ansible.log

    # ssh timeout
    timeout = 10
    $

This configures two default settings - the location of the ansible log file (set to our current directory) and the
timeout duration for SSH connections. To learn more about the configuration file please visit,

http://docs.ansible.com/ansible/intro_configuration.html


The Inventory File
==================

This is a list of systems (called hosts in ansible terminology) that you want ansible to manage. For large deployments
you can divide your infrastructure into groups. The file format allows you to define similarily named hosts using
patterns. You can also associate variables to certain hosts or groups.

Please create a folder called ``inventory``, add a file called ``vagrant.ini`` containing the following,

.. code:: bash

    $ mkdir inventory
    $ cat inventory/vagrant.ini
    192.168.77.20       ansible_user=vagrant        ansible_ssh_pass=vagrant
    $

Our inventory file mentions the IP of the host we want to manage and the credentials to use when logging into the host.
When we instruct ansible to manage a host, we also need to provide it with SSH credentials for the same.


Hello World - Ansible style
===========================

Ansible works by creating an SSH connection into the remote host and running commands to provision it according to our
specifications. I can think of no better introductory step than a basic network ping! Please run the following,

.. code:: bash

    $ ansible all -i inventory/vagrant.ini -m ping
    192.168.77.20 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    $


Explanation
-----------

We have just run an ansible ad-hoc command. When we invoked the ansible tool, we told it to target all the hosts
present in our inventory with the ``all`` argument. Next, we pointed out where our inventory file was located with
``-i inventory/vagrant.ini``. Finally, we instructed ansible to run the ping module with the ``-m ping`` argument.

And with this, we've completed our first segment. To recap; the following concepts have been covered,

- ansible.cfg
- inventory concept


To continue please refer the file 02-adhoc/README.rst
