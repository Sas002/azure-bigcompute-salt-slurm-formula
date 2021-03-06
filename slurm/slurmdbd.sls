## SLURM slurmbdb daemon config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm
  - slurm.logdir

slurm_slurmdbd:
  pkg.installed:
    - pkgs:
      - {{ slurm.pkgSlurmDBD }}
      {% if slurm.pkgSlurmSQL is defined %}
      - {{ slurm.pkgSlurmSQL }}
      {% endif %}
  service.running:
    - enable: True
    - name: {{ slurm.slurmdbd }}
    - require:
      - file: slurm_logdir
      - pkg: slurm_slurmdbd
      - service: slurm_munge
    - watch:
      - file: slurm_slurmdbd_config

slurm_slurmdbd_config:
  file.managed:
    - name: {{slurm.etcdir}}/slurmdbd.conf
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja 
    - source: salt://slurm/files/slurmdbd.conf
    - context:
        slurm: {{ slurm }}

slurm_slurmdb_default:
  file.managed:
    - name: /etc/default/{{slurm.slurmdbd}}
    - require:
      - pkg: slurm_slurmdbd
    - require_in:
      - service: slurm_slurmdbd



{################
slurmdbd:
  cmd.run:
    - name: /usr/bin/sacctmgr -i add cluster "{{ salt['pillar.get']('slurm:ClusterName','slurm') }}"
    - unless: sacctmgr show Cluster |grep -i "{{ salt['pillar.get']('slurm:ClusterName','slurm') }}"
  file.touch:
    - name: /etc/default/slurmdbd
    - onlyif:
       - file: exist_default_slurmdb
  
##################}
