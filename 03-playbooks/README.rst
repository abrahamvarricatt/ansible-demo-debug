
.. code::

        ____     __                     __                    __
       / __ \   / /  ____ _   __  __   / /_   ____   ____    / /__   _____
      / /_/ /  / /  / __ `/  / / / /  / __ \ / __ \ / __ \  / //_/  / ___/
     / ____/  / /  / /_/ /  / /_/ /  / /_/ // /_/ // /_/ / / ,<    (__  )
    /_/      /_/   \__,_/   \__, /  /_.___/ \____/ \____/ /_/|_|  /____/
                           /____/


*******************
What are playbooks?
*******************

As interesting as ad-hoc commands are, they aren't very efficient at managing large/complex tasks. This is where
playbooks come in. In laymans terms, playbooks are ansible's way of collecting ad-hoc commands to run as an ordered
sequence of steps on a remote host.

We can continue to build upon the workspace we've got at the end of segment-02.


Install NTP Playbook
====================

Create a file called ntpd-init.yml inside the workspace directory with the following contents,

.. code:: bash

    $ cat ntpd-init.yml
    ---
    - hosts: all
      become: yes
      become_method: sudo

      tasks:

      - ping:

      - name: Install NTP
        yum:
          name: ntp
          state: installed    # NOTE: not same as saying 'present'
          update_cache: yes

      - name: Copy NTP configuration
        copy:
          src: ntp.conf
          dest: /etc/ntp.conf
          mode: 644
          owner: root
          group: root
        notify: Restart NTP

      - name: Start NTPD
        service:
          name: ntpd
          state: started

      handlers:

      - name: Restart NTP
        service:
          name: ntpd
          state: restarted

We are introducing a few new concepts here, so let's go over them slowly.

Ansible playbooks are YAML files - a human readable way of writing ad-hoc commands, with organizational benefits. A
valid YAML file has ```---``` at the top (this once took me a long time to debug). In the above file, we're saying
that the commands listed should be applied to all the hosts present in the inventory file. The ``become`` and
``become_method`` are instructions to ansible saying that all the commands need to be run with ``sudo``.

Within a playbook, ad-hoc commands are referred to as tasks. Each task can be given an optional ``name`` to print
during its execution (in above example, the ping task has no name).

Tasks are sequentially executed against a target host in the order they appear in the YAML file. The exception to this
rule are handlers. Handlers are a special type of task that only execute if they have been triggered earlier. In the
above example, the task ``Copy NTP configuration`` has a notify trigger to ``Restart NTP``. This trigger will fire ONLY
if the task ``Copy NTP configuration`` completes with a changed status. If the task executes, but does not change, the
handler will not be triggered.

Handlers were designed to be used for situations that require you to restart a service or system if an associated
configuration changed - else, there's no need to run them.

Here is how you can run a playbook,

.. code:: bash

    $ ansible-playbook -i inventory/vagrant.ini ntpd-init.yml

    PLAY [all] *********************************************************************

    TASK [setup] *******************************************************************
    ok: [192.168.77.20]

    TASK [ping] ********************************************************************
    ok: [192.168.77.20]

    TASK [Install NTP] *************************************************************
    ok: [192.168.77.20]

    TASK [Copy NTP configuration] **************************************************
    ok: [192.168.77.20]

    TASK [Start NTPD] **************************************************************
    ok: [192.168.77.20]

    PLAY RECAP *********************************************************************
    192.168.77.20              : ok=5    changed=0    unreachable=0    failed=0

    $

Note that this time, instead of ``ansible`` the command we are using is ``ansible-playbook``. As before, we indicate
what is the inventory to use as well as the name of the playbook we want to execute. While the playbook executes, we
can see the status of each task against the host it runs against. At the end of a playbook run, we see a recap
summarizing the hosts and the number of tasks that passed/changed/failed against them. This information is useful to
detect anomalies in large deployments.


Templates and Variables
=======================

Instead of just copying static files over to a target host, ansible also supports the usage of Jinja2 templates. For
this, please make a new folder called ``templates`` within your workspace and add a file called ``ntp.conf.j2`` to
it with the following contents,

.. code:: bash

    $ mkdir templates
    $ cat templates/ntp.conf.j2
    # {{ ansible_managed }}
    driftfile /var/lib/ntp/drift
    restrict default nomodify notrap nopeer noquery
    restrict 127.0.0.1
    restrict ::1
    server 0.centos.pool.ntp.org iburst
    server {{ custom_ntpserver }} iburst
    includefile /etc/ntp/crypto/pw
    keys /etc/ntp/keys
    disable monitor
    $

It doesn't make much sense to talk about templates without variables - which ansible also supports. Please create a
new playbook inside your workspace named ``ntpd-template.yml`` with the following contents,

.. code:: bash

    $ cat ntpd-template.yml
    ---
    - hosts: all
      become: yes
      become_method: sudo

      vars:
        custom_ntpserver: 1.centos.pool.ntp.org

      tasks:

      - ping:

      - name: Install NTP
        yum:
          name: ntp
          state: installed    # NOTE: not same as saying 'present'
          update_cache: yes

      - name: Copy NTP templated config
        template:
          src: ntp.conf.j2
          dest: /etc/ntp.conf
          mode: 644
          owner: root
          group: root
        notify: Restart NTP

      - name: Start NTPD
        service:
          name: ntpd
          state: started

      handlers:

      - name: Restart NTP
        service:
          name: ntpd
          state: restarted
    $

Please take note of a few changes to this YAML file - we've introduced a new variable called ``custom_ntpserver`` which
is used by the new ``template`` module which replaces the older ``copy`` module. Run the playbook with,

.. code:: bash

    $ ansible-playbook -i inventory/vagrant.ini ntpd-template.yml

The output looks very satisfying, doesn't it? :)

NOTE: 

      custom variables (and a few pre-defined ansible ones) can be declared at many locations - not just in the YAML
      playbook. And templates are not the only module which uses them - they can be accessed and used by other modules
      as well. Please refer the official ansible documentation for more details.



And with this, we've completed this segment. To recap; the following concepts have been covered,

- Playbooks
- Templates
- Variables


To continue please refer the file 04-load-balancer-demo/README.rst

