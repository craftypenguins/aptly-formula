include:
  - aptly.create_repos

{% set gpgid = salt['pillar.get']('aptly:gpg_keypair_id', '') %}
{% set gpgpassphrase = salt['pillar.get']('aptly:gpg_passphrase', '') %}
{% set optional_args = [ ('gpg-key', gpgid), ('passphrase', gpgpassphrase) ] %}
{% for repo, opts in salt['pillar.get']('aptly:repos').items() %}
  {% set components_list = opts['components']|join(',') %}
  {% set prefix = opts.get('prefix', '') %} 
  {% for distribution in opts['distributions'] %}
    {% set repo_list = [] %}
    {% for component in opts['components'] %}
      {% if repo_list.append(repo + '_' + distribution + '_' + component) %} {% endif %}
    {% endfor %}
publish_{{ repo }}_{{ distribution }}_repo:
  cmd.run:
    - name: aptly publish repo -force-overwrite=true -batch=true -distribution="{{ distribution }}" -component='{{ components_list }}' -architectures='{{ salt["pillar.get"]('aptly:architectures')|join(",") }}' {% for arg in optional_args %} {% if arg[1] %} {{ "-{}={}".format(arg[0], arg[1]) }} {% endif %} {% endfor %}  {{ repo_list|join(' ') }} {% if prefix  %} {{ prefix }} {% endif %}
    - runas: aptly
    - env:
      - HOME: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    - unless: aptly publish update -force-overwrite=true -batch=true {% for arg in optional_args %} {% if arg[1] %} {{ "-{}={}".format(arg[0], arg[1]) }} {% endif %} {% endfor %} {{ distribution }} {% if prefix  %} {{ prefix }} {% endif %}
  {% endfor %}
{% endfor %}
