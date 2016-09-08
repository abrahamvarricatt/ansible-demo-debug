Basic instructions
==================

To bring up the system run,

.. code:: shell

    $ vagrant up

After bringing up the system, navigate to the 'provision' folder and run the following command,

.. code:: shell

    $ cd provision
    $ ansible-playbook site.yml -i inventories/vagrant


The system should come up now.

