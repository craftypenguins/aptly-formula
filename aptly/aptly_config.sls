{% from "aptly/map.jinja" import aptly with context %}

include:
  - aptly

aptly_homedir:
  file.directory:
    - name: {{ aptly.homedir }}
    - user: aptly
    - group: aptly
    - mode: 755
    - require:
      - user: aptly_user

aptly_systemd:
  file.managed:
    - name: /etc/systemd/system/aptly.service
    - source: salt://aptly/templates/systemd.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 755

aptly_rootdir:
  file.directory:
    - name: {{ aptly.rootdir }}
    - user: aptly
    - group: aptly
    - mode: 755
    - makedirs: True
    - require:
      - file: aptly_homedir

aptly_conf:
  file.managed:
    - name: {{ aptly.homedir }}/.aptly.conf
    - source: salt://aptly/templates/aptly.conf.jinja
    - template: jinja
    - user: aptly
    - group: aptly
    - mode: 664
    - require:
      - file: aptly_homedir

{% if aptly.secure %}
aptly_gpg_key_dir:
  file.directory:
    - name: {{ aptly.homedir }}/.gnupg
    - user: aptly
    - group: aptly
    - mode: 700
    - require:
      - file: aptly_homedir

{% set gpgprivfile = '{}/.gnupg/secret.gpg'.format(aptly.homedir) %}
# goes in a different path so it's fetchable by the pkgrepo module
{% set gpgpubfile = '{}/public/public.gpg'.format(aptly.rootdir) %}
{% set gpgid = aptly.gpg_keypair_id %}

aptly_pubdir:
  file.directory:
    - name: {{ aptly.rootdir }}/public
    - user: aptly
    - group: aptly

gpg_priv_key:
  file.managed:
    - name: {{ gpgprivfile }}
    - contents_pillar: aptly:gpg_priv_key
    - user: aptly
    - group: aptly
    - mode: 700
    - require:
      - file: aptly_gpg_key_dir

gpg_pub_key:
  file.managed:
    - name: {{ gpgpubfile }}
    - contents_pillar: aptly:gpg_pub_key
    - user: aptly
    - group: aptly
    - mode: 755
    - require:
      - file: aptly_gpg_key_dir

import_gpg_pub_key:
  cmd.run:
    - name: gpg1 --no-tty --import {{ gpgpubfile }}
    - runas: aptly
    - unless: gpg1 --no-tty --list-keys | grep '{{ gpgid }}'
    - env:
      - HOME: {{ aptly.homedir }}
    - require:
      - file: aptly_gpg_key_dir

import_gpg_priv_key:
  cmd.run:
    - name: gpg1 --no-tty --import {{ gpgprivfile }}
    - runas: aptly
    - unless: gpg1 --no-tty --list-secret-keys | grep '{{ gpgid }}'
    - env:
      - HOME: {{ aptly.homedir }}
    - require:
      - file: aptly_gpg_key_dir
{% endif %}
