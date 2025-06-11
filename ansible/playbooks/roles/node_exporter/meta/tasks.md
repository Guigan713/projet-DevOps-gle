## 1. Création du groupe système

```yml
- name: Create node_exporter group
  group:
    name: "{{ node_exporter_group }}"
    system: yes
    state: present
```
> [!NOTE]
> - Crée un groupe système dédié pour Node Exporter
> - Utilise la variable {{ node_exporter_group }} pour le nom
> - system: yes indique que c'est un groupe système (GID < 1000)

## 2. Création de l'utilisateur système

```yml
- name: Create node_exporter user
  user:
    name: "{{ node_exporter_user }}"
    group: "{{ node_exporter_group }}"
    system: yes
    shell: "{{ node_exporter_shell }}"
    home: "{{ node_exporter_home }}"
    create_home: no
    state: present
```

> [!NOTE]
> - Crée un utilisateur système pour exécuter Node Exporter
> - Associe l'utilisateur au groupe créé précédemment
> - Configure le shell et le répertoire home
> - create_home: no évite la création du répertoire personnel

## 3. Création des répertoires nécessaires

```yml
- name: Create necessary directories
  file:
    path: "{{ item }}"
    state: directory
    owner: "{{ node_exporter_user }}"
    group: "{{ node_exporter_group }}"
    mode: '0755'
  loop:
    - "{{ node_exporter_config_dir }}"
    - "{{ node_exporter_textfile_dir }}"
```

> [!NOTE]
> - Crée les répertoires de configuration et de fichiers texte
> - Définit les permissions appropriées (755)
> - Attribue la propriété à l'utilisateur/groupe node_exporter

## 4. Vérification de l'installation existante

```yml
- name: Check if node_exporter is already installed
  stat:
    path: "{{ node_exporter_binary_path }}"
  register: node_exporter_installed
```

> [!NOTE]
> - Vérifie si le binaire Node Exporter existe déjà
> - Utilise le module stat pour examiner le fichier
> - Stocke le résultat dans node_exporter_installed

## 5. Récupération de la version installée

```yml
- name: Get installed node_exporter version
  command: "{{ node_exporter_binary_path }} --version"
  register: node_exporter_current_version
  when: node_exporter_installed.stat.exists
  changed_when: false
  failed_when: false
```

> [!NOTE]
> - Exécute --version pour connaître la version actuelle
> - S'exécute uniquement si Node Exporter est déjà installé
> - changed_when: false évite de marquer la tâche comme modifiée

## 6. Téléchargement et extraction

```yml
- name: Download and extract node_exporter
  unarchive:
    src: "{{ node_exporter_binary_url }}"
    dest: "/tmp"
    remote_src: yes
    owner: root
    group: root
    mode: '0755'
  when: >
    not node_exporter_installed.stat.exists or
    (node_exporter_current_version.stdout is defined and 
     node_exporter_version not in node_exporter_current_version.stdout)
  notify: restart node_exporter
```

> [!NOTE]
> - Télécharge l'archive depuis l'URL définie
> - Extrait directement dans /tmp
> - Condition : s'exécute si pas installé OU si version différente
> - Déclenche le handler restart node_exporter

## 7. Copie du binaire

```yml
- name: Copy node_exporter binary
  copy:
    src: "/tmp/node_exporter-{{ node_exporter_version }}.linux-amd64/node_exporter"
    dest: "{{ node_exporter_binary_path }}"
    owner: root
    group: root
    mode: '0755'
    remote_src: yes
  when: >
    not node_exporter_installed.stat.exists or
    (node_exporter_current_version.stdout is defined and 
     node_exporter_version not in node_exporter_current_version.stdout)
  notify: restart node_exporter
```

> [!NOTE]
> - Copie le binaire extrait vers son emplacement final
> - Définit les permissions d'exécution (755)
> - Même condition que l'étape précédente
> - remote_src: yes car le fichier source est sur la machine cible

## 8. Nettoyage des fichiers temporaires

```yml
- name: Clean up temporary files
  file:
    path: "/tmp/node_exporter-{{ node_exporter_version }}.linux-amd64"
    state: absent
```

> [!NOTE]
> - Supprime le répertoire temporaire d'extraction
> - Maintient la propreté du système

## 9. Création du service systemd

```yml
- name: Create node_exporter systemd service
  template:
    src: node_exporter.service.j2
    dest: /etc/systemd/system/node_exporter.service
    owner: root
    group: root
    mode: '0644'
  notify:
    - reload systemd
    - restart node_exporter
```

> [!NOTE]
> - Génère le fichier de service à partir d'un template
> - Place le service dans /etc/systemd/system/
> - Déclenche les handlers pour recharger systemd et redémarrer

## 10. Démarrage et activation du service

```yml
- name: Start and enable node_exporter service
  systemd:
    name: node_exporter
    state: started
    enabled: yes
    daemon_reload: yes
```

> [!NOTE]
> - Démarre immédiatement le service
> - Active le service au boot (enabled: yes)
> - Recharge la configuration systemd

## 11. Vérification du fonctionnement

```yml
- name: Verify node_exporter is responding
  uri:
    url: "http://localhost:{{ node_exporter_port }}/metrics"
    method: GET
    timeout: 10
  register: node_exporter_health
  retries: 3
  delay: 5
  until: node_exporter_health.status == 200
```

> [!NOTE]
> - Teste l'endpoint /metrics en HTTP
> - Fait 3 tentatives avec 5 secondes d'intervalle
> - Vérifie que le code de retour est 200

## 12. Affichage du statut

```yml
- name: Display node_exporter status
  debug:
    msg: "Node Exporter is running on port {{ node_exporter_port }}"
  when: node_exporter_health.status == 200
```

> [!NOTE]
> - Affiche un message de confirmation
> - S'exécute uniquement si la vérification précédente a réussi
