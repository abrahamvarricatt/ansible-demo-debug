
.. code::

      _                           _     ____            _
     | |       ___     __ _    __| |   | __ )    __ _  | |   __ _   _ __     ___    ___   _ __
     | |      / _ \   / _` |  / _` |   |  _ \   / _` | | |  / _` | | '_ \   / __|  / _ \ | '__|
     | |___  | (_) | | (_| | | (_| |   | |_) | | (_| | | | | (_| | | | | | | (__  |  __/ | |
     |_____|  \___/   \__,_|  \__,_|   |____/   \__,_| |_|  \__,_| |_| |_|  \___|  \___| |_|


************************
What is a Load Balancer?
************************

A load balancer is a device that acts as a reverse proxy and distributes network or application traffic across a
number of servers. In layman terms, it is the device that acts as a middleman between your users and servers, helping
to route requests so that the load is evenly distributed across the different servers.


Setup Instructions
^^^^^^^^^^^^^^^^^^

We need to start with an empty ``workspace`` folder, so please delete all the data within that folder. A fresh vagrant
environment needs to be setup, so please destroy the earlier virtualsystems. Next, open the top-level ``Vagrantfile``,
comment out the parts about ``Section - 01`` and uncomment the parts about ``Section - 04``. If you've done it
correctly, running ``vagrant status`` should show you the following,

.. code:: bash

    $ cd ~/bangpy-ansible-workshop
    $ vagrant status
    Current machine states:

    loadb                     not created (virtualbox)
    webapp1                   not created (virtualbox)
    webapp2                   not created (virtualbox)
    webapp3                   not created (virtualbox)

    This environment represents multiple VMs. The VMs are all listed
    above with their current state. For more information about a specific
    VM, run `vagrant status NAME`.
    $

Please bring up all 4 virtual systems and navigate to the empty ``workspace`` folder as shown below,

.. code:: bash

    $ cd ~/bangpy-ansible-workshop
    $ vagrant up

    ...

    $
    $ vagrant status
    Current machine states:

    loadb                     running (virtualbox)
    webapp1                   running (virtualbox)
    webapp2                   running (virtualbox)
    webapp3                   running (virtualbox)

    This environment represents multiple VMs. The VMs are all listed
    above with their current state. For more information about a specific
    VM, run `vagrant status NAME`.
    $
    $ cd workspace

Let's get to work re-creating the basic files; ``ansible.cfg`` is the same as before,

.. code:: bash

    $ cat ansible.cfg
    [defaults]

    # log file location
    log_path=./ansible.log

    # ssh timeout
    timeout = 10
    $

But we've got a few changes to our inventory file. Here's how it looks like,

.. code:: bash

    $ cat inventory/vagrant.ini
    [loadbalancers]
    192.168.77.20       ansible_user=vagrant        ansible_ssh_pass=vagrant

    [webappservers]
    192.168.77.21       ansible_user=vagrant        ansible_ssh_pass=vagrant
    192.168.77.22       ansible_user=vagrant        ansible_ssh_pass=vagrant
    192.168.77.23       ansible_user=vagrant        ansible_ssh_pass=vagrant
    $

We're dividing our servers into two groups: load-balancers and webapp-servers. HA-Proxy will be installed on the
load-balancer while nginx will be installed on the webapp-servers. We can target the different groups by making use
of the ``hosts`` option within the YAML files. Here is how our main site.yml is going to look like,

.. code:: bash

    $ cat site.yml
    ---

    - hosts: webappservers
      become: yes
      become_method: sudo

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

The YAML file should be familiar enough that you recognize the different steps.

Here is the content for the haproxy template config,

.. code:: bash

    $ cat templates/haproxy.cfg.j2
    # {{ ansible_managed }}
    global
        log         127.0.0.1 local2

        chroot      /var/lib/haproxy
        pidfile     /var/run/haproxy.pid
        maxconn     4000
        user        haproxy
        group       haproxy
        daemon

        # turn on stats unix socket
        stats socket /var/lib/haproxy/stats level admin

    defaults
        mode                    http
        log                     global
        option                  httplog
        option                  dontlognull
        option http-server-close
        option forwardfor       except 127.0.0.0/8
        option                  redispatch
        retries                 3
        timeout http-request    10s
        timeout queue           1m
        timeout connect         10s
        timeout client          1m
        timeout server          1m
        timeout http-keep-alive 10s
        timeout check           10s
        maxconn                 3000

        # enable status URL
        stats enable
        stats uri /haproxy?stats

    backend app
        listen loadbalancer 192.168.77.20:80
        balance     roundrobin
        {% for host in groups['webappservers'] %}
            server {{ host }} {{ hostvars[host].ansible_all_ipv4_addresses[1] }} check port 80
        {% endfor %}
    $

The important points to note about this file, is that we've enabled a round-robin balancing scheme. That means, after
a request has been serviced by webapp1, the next request will go to webapp2 ... and so on in a round robin fashion.
For demonstration purposes, we've also enabled the haproxy status URL. You can visit it at,

http://192.168.77.20/haproxy?stats

On this status page, keep a note of the Sessions > Total entries for the different webapps. Notice how the number
changes when the main URL is hit. Speaking of which, here it is,

http://192.168.77.20/

Next let's have a look at the nginx config file,

.. code:: bash

    $ cat templates/nginx.conf.j2
    # {{ ansible_managed }}

    user nginx;
    worker_processes 1;
    error_log /var/log/nginx/error.log;
    pid /run/nginx.pid;

    include /usr/share/nginx/modules/*.conf;

    events {
        worker_connections 512;
    }

    http {
        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                          '$status $body_bytes_sent "$http_referer" '
                          '"$http_user_agent" "$http_x_forwarded_for"';

        access_log  /var/log/nginx/access.log  main;

        sendfile            off;
        tcp_nopush          on;
        tcp_nodelay         on;
        types_hash_max_size 2048;

        include             /etc/nginx/mime.types;
        default_type        application/octet-stream;

        include /etc/nginx/conf.d/*.conf;

        # https://philio.me/backend-server-host-name-as-a-custom-header-with-nginx/
        add_header X-Backend-Server $hostname;

        # disable cache used for testing
        add_header Cache-Control private;
        add_header Last-Modified "";
        expires off;
        etag off;

        server {
            listen       80 default_server;
            listen       [::]:80 default_server;
            server_name  {{ ansible_hostname }};
            root         /usr/share/nginx/html;
            index        index.html index.htm;

            # include /etc/nginx/default.d/*.conf;

            location / {
                try_files $uri $uri/ =404;
            }

            error_page 404 /404.html;
                location = /40x.html {
            }

            error_page 500 502 503 504 /50x.html;
                location = /50x.html {
            }
        }

    }
    $

What's important to note here, is that we've disabled the browser cache - for demonstration purposes (without this,
the content shown on the client browser would not change unless a force refresh was made). We are also adding an
extra header to every response which indicates which server the request came from. After the deployment is done, you
can see the extra header using the curl command,

.. code:: bash

    $ curl -I http://192.168.77.20/
    HTTP/1.1 200 OK
    Server: nginx/1.10.1
    Date: Tue, 13 Sep 2016 17:20:48 GMT
    Content-Type: text/html
    Content-Length: 1067
    X-Backend-Server: webapp3
    Cache-Control: private
    Accept-Ranges: bytes
    $

Take note of the ``X-Backend-Server`` part of the header response. Try running the same curl command a few times to
observe how it changes.

Finally lets have a peek at the index.html template file,

.. code:: bash

    $ cat templates/index.html.j2
    <!-- {{ ansible_managed }} -->
    <html>
    <title>04 Load Balancer Demo</title>

    <!--
    http://stackoverflow.com/questions/22223270/vertically-and-horizontally-center-a-div-with-css
    http://css-tricks.com/centering-in-the-unknown/
    http://jsfiddle.net/6PaXB/
    -->

    <style>
        .block {
            text-align: center;
            margin-bottom:10px;
        }
        .block:before {
            content: '';
            display: inline-block;
            height: 100%;
            vertical-align: middle;
            margin-right: -0.25em;
        }
        .centered {
            display: inline-block;
            vertical-align: middle;
            width: 300px;
        }
    </style>

    <body>
    <div class="block" style="height: 99%;">
        <div class="centered">
            <h1>Load Balancer Demo</h1>
            <p>Served by {{ ansible_hostname }} ({{ ansible_all_ipv4_addresses[1] }}).</p>
            <p>Served by {{ ansible_hostname }} ({{ ansible_all_ipv4_addresses[0] }}).</p>
            <p>{{ ansible_managed }}</p>
        </div>
    </div>
    </body>
    </html>
    $

Not much to say about this one. Thanks to ansible template management, we're able to get the hostname and IP of the
remote host where the file gets deployed to and use that as content.

With all the files in place, you can perform the deployment by running,

.. code:: bash

    $ ansible-playbook -i inventory/vagrant.ini site.yml

Feel free to experiment around. Be amazed at how easy it is to configure a cluster of web servers behind a
load balancer. Open ``http://192.168.77.20/`` in your web-browser and hit refresh a few times. See the load balancer
in action! :)




To continue please refer the file 05-zero-downtime-deployments/README.rst

