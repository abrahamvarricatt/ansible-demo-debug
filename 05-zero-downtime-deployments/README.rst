
.. code::

     _______  _______  ______    _______        ______   _______  _     _  __    _  _______  ___   __   __  _______
    |       ||       ||    _ |  |       |      |      | |       || | _ | ||  |  | ||       ||   | |  |_|  ||       |
    |____   ||    ___||   | ||  |   _   |      |  _    ||   _   || || || ||   |_| ||_     _||   | |       ||    ___|
     ____|  ||   |___ |   |_||_ |  | |  |      | | |   ||  | |  ||       ||       |  |   |  |   | |       ||   |___
    | ______||    ___||    __  ||  |_|  |      | |_|   ||  |_|  ||       ||  _    |  |   |  |   | |       ||    ___|
    | |_____ |   |___ |   |  | ||       |      |       ||       ||   _   || | |   |  |   |  |   | | ||_|| ||   |___
    |_______||_______||___|  |_||_______|      |______| |_______||__| |__||_|  |__|  |___|  |___| |_|   |_||_______|



************************
What zero downtime mean?
************************

Have you ever visited a website, only to encounter an error page? Or even worse - to get a message along the lines of
'server did not respond' ? These are instances of downtime. Zero downtime is a term that means the website never went
down. It is beyond the scope of this workshop to provide a solution to every possible cause of downtime (that's what
you pay engineers for!), but we ARE going to be concerned about downtimes during system upgrades.

What this segment aims to show, is a method of deployment by which you can deploy an upgraded version of a web-site in
a seamless and transparent manner.

Fortunately, we can continue to build upon the workspace we've got at the end of segment-04.


How to plan a zero downtime upgrade?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For simplicity's sake, let us assume that an upgrade means to deploy a new version of our ``index.html`` on all our
application servers. To allow visitors to continue using our website, we need to perform this upgrade on one server
at a time. Before an upgrade is initiated on a server, the load balancer needs to be informed - to configure said
application server into maintenance mode. After the upgrade is complete, the load balancer needs to restore it back
into the pool of available systems. If we think of the upgrade process as a sequence of tasks, then what we need is
some kind of pre-task and post-task activity to deactivate and later activate the server on the load balancer. These
are the same keywords that ansible provides to perform this function.

For this to work however, the tasks need to be performed sequentially - i.e. one application server upgrade at a time.
It is now that we should be reminded of how ansible actually runs a playbook.


Parallel vs Serial playbooks
============================

For demonstration purposes, please create a playbook called ``task-demo.yml`` inside your workspace with the following
content,

.. code:: bash

    $ cat task-demo.yml
    ---

    - hosts: all

      tasks:

      - name: Sleep for a bit
        shell: /bin/sleep 5
    $

Let's time how long this takes to complete,

.. code:: bash

    $ time ansible-playbook -i inventory/vagrant.ini task-demo.yml

    PLAY [all] *********************************************************************

    TASK [setup] *******************************************************************
    ok: [192.168.77.23]
    ok: [192.168.77.21]
    ok: [192.168.77.22]
    ok: [192.168.77.20]

    TASK [Sleep for a bit] *********************************************************
    changed: [192.168.77.23]
    changed: [192.168.77.22]
    changed: [192.168.77.21]
    changed: [192.168.77.20]

    PLAY RECAP *********************************************************************
    192.168.77.20              : ok=2    changed=1    unreachable=0    failed=0
    192.168.77.21              : ok=2    changed=1    unreachable=0    failed=0
    192.168.77.22              : ok=2    changed=1    unreachable=0    failed=0
    192.168.77.23              : ok=2    changed=1    unreachable=0    failed=0


    real	0m6.169s
    user	0m1.552s
    sys	0m0.368s
    $

About 6 seconds; which clearly implies that the tasks are executing in parallel - not the kind of thing we can use
for our zero deployment scheme. Fortunately, there exists a simple way to force ansible to perform it's actions in a
serial manner. To demonstrate this, please create a new playbook called ``task-demo-serial.yml`` with the following
content,

.. code:: bash

    $ cat task-demo-serial.yml
    ---

    - hosts: all
      serial: 1

      tasks:

      - name: Sleep for a bit
        shell: /bin/sleep 5
    $

The change is the additional ``serial: 1`` line below the hosts entry. Let's try timing this,

.. code:: bash

    $ time ansible-playbook -i inventory/vagrant.ini task-demo-serial.yml

    PLAY [all] *********************************************************************

    TASK [setup] *******************************************************************
    ok: [192.168.77.20]

    TASK [Sleep for a bit] *********************************************************
    changed: [192.168.77.20]

    PLAY [all] *********************************************************************

    TASK [setup] *******************************************************************
    ok: [192.168.77.21]

    TASK [Sleep for a bit] *********************************************************
    changed: [192.168.77.21]

    PLAY [all] *********************************************************************

    TASK [setup] *******************************************************************
    ok: [192.168.77.22]

    TASK [Sleep for a bit] *********************************************************
    changed: [192.168.77.22]

    PLAY [all] *********************************************************************

    TASK [setup] *******************************************************************
    ok: [192.168.77.23]

    TASK [Sleep for a bit] *********************************************************
    changed: [192.168.77.23]

    PLAY RECAP *********************************************************************
    192.168.77.20              : ok=2    changed=1    unreachable=0    failed=0
    192.168.77.21              : ok=2    changed=1    unreachable=0    failed=0
    192.168.77.22              : ok=2    changed=1    unreachable=0    failed=0
    192.168.77.23              : ok=2    changed=1    unreachable=0    failed=0


    real	0m23.334s
    user	0m2.748s
    sys	0m0.476s
    $

More than 20 seconds. Sounds about right, just what we were looking for!!

NOTE: The matter of serial/parallel execution of tasks is more complicated that what is presented here. For example,
you can configure an ansible playbook to parallely execute only 30% of your inventory during an upgrade - it will
depend on your circumstances. Please refer the ``Continous Delivery and Rolling Upgrades`` section of the official
Ansible documentation for details.


haproxy maintainence mode
=========================

Before we get to our finale, a little about haproxy configuration - we've configured haproxy to listen to a socket on
the local filesystem. Thus while haproxy is running, we can issue commands to this socket which will be interpreted
by haproxy as management stuff. To demonstrate this, please login to the loadbalancer and enter root mode (to avoid
hassels with file permissions),

.. code:: bash

    $ vagrant ssh loadb
    $ sudo su -
    # echo "disable server loadbalancer/192.168.77.21" | socat stdio /var/lib/haproxy/stats

    #

At this point, if you visit the haproxy statistics page ( http://192.168.77.20/haproxy?stats ) you'll see that one of
the frontend servers is in maintenance mode. To bring it back up just run the following in the earlier session,

.. code:: bash

    # echo "enable server loadbalancer/192.168.77.21" | socat stdio /var/lib/haproxy/stats

    # exit
    $ exit

Don't forget to quit from the root session!


The Zero Downtime Deployment
============================

Please create a new YAML file called ``zero-downtime.yml`` in your workspace with the following content,

.. code:: bash

    $ cat zero-downtime.yml
    ---

    - hosts: webappservers
      become: yes
      become_method: sudo
      serial: 1

      pre_tasks:

      - name: Disable server in haproxy
        shell: echo "disable server loadbalancer/{{ inventory_hostname }}" | socat stdio /var/lib/haproxy/stats
        delegate_to: "{{ item }}"
        with_items:
          - "{{ groups.loadbalancers }}"

      tasks:

      - name: Install EPEL repository
        yum:
          name: epel-release
          state: installed

      - name: Install nginx
        yum:
          name: nginx
          state: installed

      - name: Copy over nginx.conf
        template:
          src: nginx.conf.j2
          dest: /etc/nginx/nginx.conf
        notify: Restart nginx

      - name: Pretend upgrade by cleaning out content
        file:
          path: /usr/share/nginx/html/index.html
          state: absent

      - name: Copy over webapp content
        template:
          src: index.html.j2
          dest: /usr/share/nginx/html/index.html
        notify: Restart nginx

      handlers:

      - name: Restart nginx
        service:
          name: nginx
          state: restarted

      post_tasks:

      - name: Re-enable server in haproxy
        shell: echo "enable server loadbalancer/{{ inventory_hostname }}" | socat stdio /var/lib/haproxy/stats
        delegate_to: "{{ item }}"
        with_items:
          - "{{ groups.loadbalancers }}"

    #############################################################
    #############################################################

    - hosts: loadbalancers
      become: yes
      become_method: sudo

      tasks:

      - name: Install haproxy and socat
        yum: name="{{ item }}" state=installed
        with_items:
          - haproxy
          - socat

      - name: Copy over haproxy.cfg
        template:
          src: haproxy.cfg.j2
          dest: /etc/haproxy/haproxy.cfg
        notify: Restart haproxy

      handlers:

      - name: Restart haproxy
        service:
          name: haproxy
          state: restarted
    $

Make note of the new ``pre_tasks`` and ``post_tasks`` sections. They define the tasks that need to be run before and
after the main task list. Also make note of the ``delegate_to`` section within them. This is an ansible way of saying
that those tasks need to be run on a different host. In our case, retrieve that data from the inventory file, as a
group.

As you run the playbook with,

.. code:: bash

    $ time ansible-playbook -i inventory/vagrant.ini zero-downtime.yml

Try refreshing the haproxy status link ( http://192.168.77.20/haproxy?stats ) on your browser. It's nice to watch the
servers get taken down and brought back up.

And that's it for this workshop. It took me a lot of effort to prepare this material and I hope you found the whole
session useful! Feel free to get in touch with me if you have any queries. :)

