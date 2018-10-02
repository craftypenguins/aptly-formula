/etc/systemd/system/aptly.service:
  file.managed:
    - contents: |
        #Saltstack managed file 
        [Unit]
        Description=Aptly REST API service

        [Service]
        User=aptly
        Group=aptly
        WorkingDirectory={{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
        ExecStart=/usr/bin/aptly api serve -no-lock -listen ":{{ salt['pillar.get']('aptly:port', '8081') }}"

        [Install]
        WantedBy=multi-user.target
