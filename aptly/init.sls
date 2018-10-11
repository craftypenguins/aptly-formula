{% from "aptly/map.jinja" import aptly with context %}

aptly_repo:
  pkgrepo.managed:
    - humanname: Aptly PPA
    - name: deb http://repo.aptly.info/ squeeze main
    - dist: squeeze
    - file: /etc/apt/sources.list.d/aptly.list
    - keyid: ED75B5A4483DA07C
    - keyserver: keys.gnupg.net
    - require_in:
      - pkg: aptly

aptly:
  pkg.installed:
    - refresh: True
    - pkgs:
{% for item in aptly.pkgs %}
      - {{ item }}
{% endfor %}

aptly_user:
  user.present:
    - name: aptly
    - shell: /bin/bash
    - home: {{ aptly.homedir }}
    - require:
      - pkg: aptly
    - uid: {{ aptly.user.uid }}
    - gid: {{ aptly.user.gid }}
    - gid_from_name: True
