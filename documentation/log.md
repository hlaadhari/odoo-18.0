PS H:\Users\GitHub\odoo-18.0> .\steg-addons.ps1 refresh
🔄 Mise à jour du monorepo odoo-18.0...
Already up to date.
✅ Monorepo mis à jour
🔄 Redémarrage du service Odoo (odoo)...
Erreur: This command cannot be run due to the error: Le fichier spécifié est introuvable.
PS H:\Users\GitHub\odoo-18.0> .\steg-addons.ps1 refresh
🔄 Mise à jour du monorepo odoo-18.0...
Already up to date.
✅ Monorepo mis à jour
🔄 Redémarrage du service Odoo (odoo)...
Utilisation de: docker compose -f H:\Users\GitHub\odoo-18.0\docker-compose-simple.yml restart odoo
[+] Restarting 1/1
 ✔ Container odoo_steg_app_simple  Started                                                                                          1.4s 
✅ Service Odoo redémarré
Terminé. Monorepo mis à jour et Odoo redémarré.
PS H:\Users\GitHub\odoo-18.0> .\steg-addons.ps1 help   
STEG Addons Sync - Téléchargement et mise à jour d'addons Odoo (Docker)

USAGE:
  .\steg-addons.ps1 download -GitUrls <url1> [<url2> ...] [-NoRestart]
  .\steg-addons.ps1 sync -SourceLocalDir <path> [-Addons <name1,name2>] [-NoRestart]
  .\steg-addons.ps1 update [-Addons <name1,name2>] [-NoRestart]
  .\steg-addons.ps1 refresh [-NoRestart]
  .\steg-addons.ps1 help

DÉTAILS:
  download   Clône un ou plusieurs dépôts Git d'addons dans custom_addons.
  sync       Copie (miroir) des dossiers addons depuis un dossier source local vers custom_addons.
  update     Met à jour (git pull) les addons déjà clonés (dossiers contenant .git) dans custom_addons.
  refresh    Met à jour le monorepo odoo-18.0 (git pull) et redémarre Odoo.

OPTIONS:
  -ComposeFile   Fichier docker compose (defaut: docker-compose-simple.yml)
  -ServiceName   Nom du service dans compose (defaut: odoo)
  -NoRestart     N'effectue pas de redémarrage de service après l'opération

EXEMPLES:
  # Mettre à jour le monorepo et redémarrer Odoo (cas d'usage principal)
  .\steg-addons.ps1 refresh

  # Télécharger des addons depuis des dépôts Git séparés
  .\steg-addons.ps1 download -GitUrls https://github.com/org/addon1.git,https://github.com/org/addon2.git

  # Synchroniser des addons depuis un dossier local
  .\steg-addons.ps1 sync -SourceLocalDir .\addon_source -Addons steg_stock_management,steg_barcode

  # Mettre à jour uniquement certains addons Git dans custom_addons
  .\steg-addons.ps1 update -Addons steg_stock_management,steg_barcode

  # Redémarrer Odoo sans mise à jour
  .\steg-addons.ps1 refresh -NoRestart
  docker compose restart odoo
PS H:\Users\GitHub\odoo-18.0> .\steg-addons.ps1 update -NoRestart
⏭  Pas un dépôt Git, aucun update automatique: steg_barcode
⏭  Pas un dépôt Git, aucun update automatique: steg_stock_management
Terminé. Mis à jour:
PS H:\Users\GitHub\odoo-18.0> docker compose -f docker-compose-simple.yml ps   
NAME                   IMAGE         COMMAND                  SERVICE   CREATED       STATUS                 PORTS
odoo_steg_app_simple   odoo:18.0     "/entrypoint.sh odoo"    odoo      10 days ago   Up 3 minutes           0.0.0.0:8069->8069/tcp, [::]:8069->8069/tcp
odoo_steg_db_simple    postgres:15   "docker-entrypoint.s…"   db        10 days ago   Up 4 hours (healthy)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
PS H:\Users\GitHub\odoo-18.0> docker compose -f docker-compose-simple.yml logs odoo --tail=50
odoo_steg_app_simple  | 2025-08-21 11:45:48,120 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Procurement: run scheduler' (17) processed 3 records, 0 records remaining
odoo_steg_app_simple  | 2025-08-21 11:45:48,121 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Procurement: run scheduler' (17) completed
odoo_steg_app_simple  | 2025-08-21 11:45:48,127 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Account: Post draft entries with auto_post enabled and accounting date up to today' (19) starting
odoo_steg_app_simple  | 2025-08-21 11:45:48,136 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Account: Post draft entries with auto_post enabled and accounting date up to today' (19) done in 0.009s
odoo_steg_app_simple  | 2025-08-21 11:45:48,139 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Account: Post draft entries with auto_post enabled and accounting date up to today' (19) processed 0 records, 0 records remaining
odoo_steg_app_simple  | 2025-08-21 11:45:48,140 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Account: Post draft entries with auto_post enabled and accounting date up to today' (19) completed
odoo_steg_app_simple  | 2025-08-21 11:45:48,147 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Send invoices automatically' (20) starting
odoo_steg_app_simple  | 2025-08-21 11:45:48,149 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Send invoices automatically' (20) done in 0.002s
odoo_steg_app_simple  | 2025-08-21 11:45:48,152 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Send invoices automatically' (20) processed 0 records, 0 records remaining
odoo_steg_app_simple  | 2025-08-21 11:45:48,154 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Send invoices automatically' (20) completed
odoo_steg_app_simple  | 2025-08-21 11:45:48,159 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Sales: Send pending emails' (22) starting
odoo_steg_app_simple  | 2025-08-21 11:45:48,161 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Sales: Send pending emails' (22) done in 0.002s
odoo_steg_app_simple  | 2025-08-21 11:45:48,163 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Sales: Send pending emails' (22) processed 0 records, 0 records remaining
odoo_steg_app_simple  | 2025-08-21 11:45:48,165 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Sales: Send pending emails' (22) completed
odoo_steg_app_simple  | 2025-08-21 11:45:48,170 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Purchase reminder' (24) starting 
odoo_steg_app_simple  | 2025-08-21 11:45:48,185 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Purchase reminder' (24) done in 0.014s
odoo_steg_app_simple  | 2025-08-21 11:45:48,187 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Purchase reminder' (24) processed 0 records, 0 records remaining
odoo_steg_app_simple  | 2025-08-21 11:45:48,189 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Purchase reminder' (24) completed

odoo_steg_app_simple  | 2025-08-21 11:45:48,193 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Mail: Email Queue Manager' (3) starting
odoo_steg_app_simple  | 2025-08-21 11:45:48,198 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Mail: Email Queue Manager' (3) done in 0.005s
odoo_steg_app_simple  | 2025-08-21 11:45:48,200 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Mail: Email Queue Manager' (3) processed 0 records, 0 records remaining
odoo_steg_app_simple  | 2025-08-21 11:45:48,202 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Mail: Email Queue Manager' (3) completed
odoo_steg_app_simple  | 2025-08-21 11:45:48,207 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Users: Notify About Unregistered Users' (12) starting
odoo_steg_app_simple  | 2025-08-21 11:45:48,210 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Users: Notify About Unregistered Users' (12) done in 0.003s
odoo_steg_app_simple  | 2025-08-21 11:45:48,213 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Users: Notify About Unregistered Users' (12) processed 0 records, 0 records remaining
odoo_steg_app_simple  | 2025-08-21 11:45:48,214 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Users: Notify About Unregistered Users' (12) completed
odoo_steg_app_simple  | 2025-08-21 11:45:48,219 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Partner Autocomplete: Sync with remote DB' (13) starting
odoo_steg_app_simple  | 2025-08-21 11:45:48,221 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Partner Autocomplete: Sync with remote DB' (13) done in 0.001s
odoo_steg_app_simple  | 2025-08-21 11:45:48,223 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Partner Autocomplete: Sync with remote DB' (13) processed 0 records, 0 records remaining
odoo_steg_app_simple  | 2025-08-21 11:45:48,225 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Partner Autocomplete: Sync with remote DB' (13) completed
odoo_steg_app_simple  | 2025-08-21 11:45:48,230 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Base: Portal Users Deletion' (2) starting
odoo_steg_app_simple  | 2025-08-21 11:45:48,233 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Base: Portal Users Deletion' (2) done in 0.003s
odoo_steg_app_simple  | 2025-08-21 11:45:48,235 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Base: Portal Users Deletion' (2) processed 0 records, 0 records remaining
odoo_steg_app_simple  | 2025-08-21 11:45:48,237 1 INFO steg_stock odoo.addons.base.models.ir_cron: Job 'Base: Portal Users Deletion' (2) completed
odoo_steg_app_simple  | 2025-08-21 11:46:04,541 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "GET /odoo/apps HTTP/1.1" 200 - 19 0.005 0.011
odoo_steg_app_simple  | 2025-08-21 11:46:04,753 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "GET /bus/websocket_worker_bundle?v=18.0-5 HTTP/1.1" 304 - 3 0.001 0.003
odoo_steg_app_simple  | 2025-08-21 11:46:04,805 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "GET /web/image?model=res.users&field=avatar_128&id=2 HTTP/1.1" 304 - 9 0.009 0.015
odoo_steg_app_simple  | 2025-08-21 11:46:04,805 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /web/action/load HTTP/1.1" 200 - 11 0.008 0.013
odoo_steg_app_simple  | 2025-08-21 11:46:04,810 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "GET /websocket?version=18.0-5 HTTP/1.1" 101 - 1 0.001 0.018
odoo_steg_app_simple  | 2025-08-21 11:46:04,816 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "GET /web/manifest.webmanifest HTTP/1.1" 200 - 7 0.007 0.019
odoo_steg_app_simple  | 2025-08-21 11:46:04,829 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /web/dataset/call_kw/ir.module.module/get_views HTTP/1.1" 200 - 2 0.001 0.015
odoo_steg_app_simple  | 2025-08-21 11:46:04,839 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /mail/data HTTP/1.1" 200 - 30 0.021 0.032
odoo_steg_app_simple  | 2025-08-21 11:46:04,850 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 1 0.001 0.005
odoo_steg_app_simple  | 2025-08-21 11:46:04,867 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /web/dataset/call_kw/ir.module.module/web_search_read HTTP/1.1" 200 - 3 0.003 0.018
odoo_steg_app_simple  | 2025-08-21 11:46:04,872 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 48 0.016 0.011
odoo_steg_app_simple  | 2025-08-21 11:46:06,505 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:06] "GET /web/service-worker.js HTTP/1.1" 200 - 1 0.000 0.002
odoo_steg_app_simple  | 2025-08-21 11:46:11,921 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:11] "POST /web/dataset/call_kw/ir.module.module/web_search_read HTTP/1.1" 200 - 5 0.002 0.005
odoo_steg_app_simple  | 2025-08-21 11:46:11,934 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:11] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 48 0.011 0.009
odoo_steg_app_simple  | 2025-08-21 11:46:14,393 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:14] "POST /web/dataset/call_kw/ir.module.module/web_search_read HTTP/1.1" 200 - 3 0.002 0.014
odoo_steg_app_simple  | 2025-08-21 11:46:14,400 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:14] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 48 0.014 0.011
PS H:\Users\GitHub\odoo-18.0> docker exec odoo_steg_app_simple ls -la /mnt/extra-addons/
total 4
drwxrwxrwx 1 root root 4096 Aug 12 08:11 .
drwxr-xr-x 1 root root 4096 Jul 25 17:11 ..
drwxrwxrwx 1 root root 4096 Aug  8 08:36 steg_barcode
drwxrwxrwx 1 root root 4096 Aug 12 08:18 steg_stock_management
PS H:\Users\GitHub\odoo-18.0> docker exec odoo_steg_app_simple odoo -d steg_stock --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons --list-db
Usage: odoo server [options]

odoo server: error: no such option: --list-db
PS H:\Users\GitHub\odoo-18.0> docker exec odoo_steg_app_simple odoo -d steg_stock --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons --update-list --stop-after-init
Usage: odoo server [options]

odoo server: error: no such option: --update-list
PS H:\Users\GitHub\odoo-18.0> docker exec odoo_steg_app_simple odoo -d steg_stock --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons -u base --stop-after-init      
2025-08-21 11:47:02,689 79 INFO ? odoo: Odoo version 18.0-20250725 
2025-08-21 11:47:02,689 79 INFO ? odoo: Using configuration file at /etc/odoo/odoo.conf
2025-08-21 11:47:02,690 79 INFO ? odoo: addons paths: ['/usr/lib/python3/dist-packages/odoo/addons', '/var/lib/odoo/addons/18.0', '/mnt/extra-addons']
2025-08-21 11:47:02,690 79 INFO ? odoo: database: default@default:default
2025-08-21 11:47:02,690 79 INFO ? odoo.sql_db: Connection to the database failed 
Traceback (most recent call last):
  File "/usr/bin/odoo", line 8, in <module>
    odoo.cli.main()
  File "/usr/lib/python3/dist-packages/odoo/cli/command.py", line 66, in main
    o.run(args)
  File "/usr/lib/python3/dist-packages/odoo/cli/server.py", line 182, in run
    main(args)
  File "/usr/lib/python3/dist-packages/odoo/cli/server.py", line 153, in main
    odoo.service.db._create_empty_database(db_name)
  File "/usr/lib/python3/dist-packages/odoo/service/db.py", line 107, in _create_empty_database
    with closing(db.cursor()) as cr:
                 ^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/sql_db.py", line 796, in cursor
    return Cursor(self.__pool, self.__dbname, self.__dsn)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/sql_db.py", line 288, in __init__
    self._cnx = pool.borrow(dsn)
                ^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/decorator.py", line 232, in fun
    return caller(func, *(extras + args), **kw)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/tools/func.py", line 97, in locked
    return func(inst, *args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/sql_db.py", line 723, in borrow
    result = psycopg2.connect(
             ^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/psycopg2/__init__.py", line 122, in connect
    conn = _connect(dsn, connection_factory=connection_factory, **kwasync)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
psycopg2.OperationalError: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: No such file or directory
        Is the server running locally and accepting connections on that socket?

PS H:\Users\GitHub\odoo-18.0> python update_module_list.py 
Traceback (most recent call last):
  File "H:\Users\GitHub\odoo-18.0\update_module_list.py", line 5, in <module>
    import requests
ModuleNotFoundError: No module named 'requests'
PS H:\Users\GitHub\odoo-18.0> pip install requests
Defaulting to user installation because normal site-packages is not writeable
Collecting requests
  Downloading requests-2.32.5-py3-none-any.whl.metadata (4.9 kB)
Collecting charset_normalizer<4,>=2 (from requests)
  Downloading charset_normalizer-3.4.3-cp313-cp313-win_amd64.whl.metadata (37 kB)
Collecting idna<4,>=2.5 (from requests)
  Downloading idna-3.10-py3-none-any.whl.metadata (10 kB)
Collecting urllib3<3,>=1.21.1 (from requests)
  Downloading urllib3-2.5.0-py3-none-any.whl.metadata (6.5 kB)
Collecting certifi>=2017.4.17 (from requests)
  Downloading certifi-2025.8.3-py3-none-any.whl.metadata (2.4 kB)
Downloading requests-2.32.5-py3-none-any.whl (64 kB)
Downloading charset_normalizer-3.4.3-cp313-cp313-win_amd64.whl (107 kB)
Downloading idna-3.10-py3-none-any.whl (70 kB)
Downloading urllib3-2.5.0-py3-none-any.whl (129 kB)
Downloading certifi-2025.8.3-py3-none-any.whl (161 kB)
Installing collected packages: urllib3, idna, charset_normalizer, certifi, requests
   ━━━━━━━━━━━━━━━━╺━━━━━━━━━━━━━━━━━━━━━━━ 2/5 [charset_normalizer]  WARNING: The script normalizer.exe is installed in 'C:\Users\hatem\AppData\Roaming\Python\Python313\Scripts' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Successfully installed certifi-2025.8.3 charset_normalizer-3.4.3 idna-3.10 requests-2.32.5 urllib3-2.5.0                                 

[notice] A new release of pip is available: 25.1.1 -> 25.2
[notice] To update, run: python.exe -m pip install --upgrade pip
PS H:\Users\GitHub\odoo-18.0> python update_module_list.py
🔄 Connexion à Odoo...
Erreur d'authentification: {'code': 200, 'message': 'Odoo Server Error', 'data': {'name': 'odoo.exceptions.AccessDenied', 'debug': 'Traceback (most recent call last):\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2123, in _transactioning\n    return service_model.retrying(func, env=self.env)\n           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/service/model.py", line 156, in retrying\n    result = func()\n             ^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2090, in _serve_ir_http\n    response = self.dispatcher.dispatch(rule.endpoint, args)\n               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2338, in dispatch\n    result = self.request.registry[\'ir.http\']._dispatch(endpoint)\n             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/ir_http.py", line 333, in _dispatch\n    result = endpoint(**request.params)\n             ^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 754, in route_wrapper\n    result = endpoint(self, *args, **params_ok)\n             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/web/controllers/session.py", line 38, in authenticate\n    auth_info = request.session.authenticate(db, credential)\n                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 1071, in authenticate\n    auth_info = registry[\'res.users\'].authenticate(dbname, credential, wsgienv)\n                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/auth_signup/models/res_users.py", line 121, in authenticate\n    auth_info = super().authenticate(db, credential, user_agent_env)\n                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/res_users.py", line 964, in authenticate\n    auth_info = cls._login(db, credential, user_agent_env=user_agent_env)\n         
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/res_users.py", line 934, in _login\n    auth_info = user._check_credentials(credential, user_agent_env)\n                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/res_users.py", line 2304, in _check_credentials\n    return super()._check_credentials(credential, user_agent_env)\n           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/res_users.py", line 499, in _check_credentials\n    raise AccessDenied()\nodoo.exceptions.AccessDenied: Access Denied\n', 'message': 'Access Denied', 'arguments': ['Access Denied'], 'context': {}}}
PS H:\Users\GitHub\odoo-18.0> python update_module_list.py
🔄 Connexion à Odoo...
Erreur d'authentification: {'code': 200, 'message': 'Odoo Server Error', 'data': {'name': 'odoo.exceptions.AccessDenied', 'debug': 'Traceback (most recent call last):\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2123, in _transactioning\n    return service_model.retrying(func, env=self.env)\n           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/service/model.py", line 156, in retrying\n    result = func()\n             ^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2090, in _serve_ir_http\n    response = self.dispatcher.dispatch(rule.endpoint, args)\n               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2338, in dispatch\n    result = self.request.registry[\'ir.http\']._dispatch(endpoint)\n             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/ir_http.py", line 333, in _dispatch\n    result = endpoint(**request.params)\n             ^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 754, in route_wrapper\n    result = endpoint(self, *args, **params_ok)\n             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/web/controllers/session.py", line 38, in authenticate\n    auth_info = request.session.authenticate(db, credential)\n                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/http.py", line 1071, in authenticate\n    auth_info = registry[\'res.users\'].authenticate(dbname, credential, wsgienv)\n                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/auth_signup/models/res_users.py", line 121, in authenticate\n    auth_info = super().authenticate(db, credential, user_agent_env)\n                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/res_users.py", line 964, in authenticate\n    auth_info = cls._login(db, credential, user_agent_env=user_agent_env)\n         
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/res_users.py", line 932, in _login\n    raise AccessDenied()\nodoo.exceptions.AccessDenied: Access Denied\n', 'message': 'Access Denied', 'arguments': ['Access Denied'], 'context': {}}}
PS H:\Users\GitHub\odoo-18.0> .\update-modules.ps1
=== MISE À JOUR DES MODULES STEG ===
🔄 Mise à jour de la liste des modules via le conteneur Docker...
Arrêt temporaire d'Odoo...
[+] Stopping 1/1
 ✔ Container odoo_steg_app_simple  Stopped0.8s  
Démarrage d'Odoo avec mise à jour de la liste des modules...
Redémarrage normal d'Odoo...
[+] Running 2/2
 ✔ Container odoo_steg_db_simple   Healthy0.5s 
 ✔ Container odoo_steg_app_simple  Started0.2s  
Attente du démarrage d'Odoo...
✅ Mise à jour de la liste des modules terminée
🔍 Test de connexion à Odoo...
✅ Odoo est accessible                                                                                                  
📋 INSTRUCTIONS POUR VOIR VOS MODULES STEG:

1. Ouvrez votre navigateur et allez sur: http://localhost:8069
2. Connectez-vous avec vos identifiants
3. Allez dans Apps (Applications)
4. Cliquez sur "Update Apps List" (Mettre à jour la liste des apps)
5. Recherchez "STEG" dans la barre de recherche
6. Vos modules devraient maintenant apparaître:
   - STEG Stock Management
   - STEG - Codes-barres et Scan

💡 Si les modules n'apparaissent toujours pas:
   - Vérifiez que les fichiers __manifest__.py sont corrects
   - Redémarrez Odoo: .\steg-addons.ps1 refresh
   - Vérifiez les logs: docker compose logs odoo --tail=100
PS H:\Users\GitHub\odoo-18.0> docker compose logs odoo --tail=50                                                                         
yaml: unmarshal errors:
  line 1: cannot unmarshal !!str `Fake file` into cli.named
PS H:\Users\GitHub\odoo-18.0> docker compose -f docker-compose-simple.yml logs odoo --tail=50
odoo_steg_app_simple  | 2025-08-21 11:46:04,829 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /web/dataset/call_kw/ir.module.module/get_views HTTP/1.1" 200 - 2 0.001 0.015
odoo_steg_app_simple  | 2025-08-21 11:46:04,839 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /mail/data HTTP/1.1" 200 - 30 0.021 0.032
odoo_steg_app_simple  | 2025-08-21 11:46:04,850 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 1 0.001 0.005
odoo_steg_app_simple  | 2025-08-21 11:46:04,867 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /web/dataset/call_kw/ir.module.module/web_search_read HTTP/1.1" 200 - 3 0.003 0.018
odoo_steg_app_simple  | 2025-08-21 11:46:04,872 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:04] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 48 0.016 0.011
odoo_steg_app_simple  | 2025-08-21 11:46:06,505 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:06] "GET /web/service-worker.js HTTP/1.1" 200 - 1 0.000 0.002
odoo_steg_app_simple  | 2025-08-21 11:46:11,921 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:11] "POST /web/dataset/call_kw/ir.module.module/web_search_read HTTP/1.1" 200 - 5 0.002 0.005
odoo_steg_app_simple  | 2025-08-21 11:46:11,934 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:11] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 48 0.011 0.009
odoo_steg_app_simple  | 2025-08-21 11:46:14,393 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:14] "POST /web/dataset/call_kw/ir.module.module/web_search_read HTTP/1.1" 200 - 3 0.002 0.014
odoo_steg_app_simple  | 2025-08-21 11:46:14,400 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:46:14] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 48 0.014 0.011
odoo_steg_app_simple  | 2025-08-21 11:49:45,698 1 INFO steg_stock odoo.addons.base.models.res_users: Login failed for db:steg_stock login:admin@steg.com.tn from 172.18.0.1
odoo_steg_app_simple  | 2025-08-21 11:49:45,703 1 WARNING steg_stock odoo.http: Access Denied
odoo_steg_app_simple  | 2025-08-21 11:49:45,703 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:49:45] "POST /web/session/authenticate HTTP/1.1" 200 - 10 0.013 0.319
odoo_steg_app_simple  | 2025-08-21 11:49:58,260 1 INFO steg_stock odoo.addons.base.models.res_users: Login failed for db:steg_stock login:admin from 172.18.0.1
odoo_steg_app_simple  | 2025-08-21 11:49:58,260 1 WARNING steg_stock odoo.http: Access Denied
odoo_steg_app_simple  | 2025-08-21 11:49:58,261 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:49:58] "POST /web/session/authenticate HTTP/1.1" 200 - 6 0.003 0.012
odoo_steg_app_simple  | 2025-08-21 11:50:28,141 1 INFO ? odoo.service.server: Initiating shutdown
odoo_steg_app_simple  | 2025-08-21 11:50:28,142 1 INFO ? odoo.service.server: Hit CTRL-C again or send a second signal to force the shutdown.
odoo_steg_app_simple  | 2025-08-21 11:50:28,356 1 INFO ? odoo.sql_db: ConnectionPool(read/write;used=0/count=0/max=64): Closed 7 connections
odoo_steg_app_simple  | 2025-08-21 11:50:31,915 1 INFO ? odoo: Odoo version 18.0-20250725
odoo_steg_app_simple  | 2025-08-21 11:50:31,915 1 INFO ? odoo: Using configuration file at /etc/odoo/odoo.conf
odoo_steg_app_simple  | 2025-08-21 11:50:31,915 1 INFO ? odoo: addons paths: ['/usr/lib/python3/dist-packages/odoo/addons', '/var/lib/odoo/addons/18.0', '/mnt/extra-addons']
odoo_steg_app_simple  | 2025-08-21 11:50:31,916 1 INFO ? odoo: database: odoo@db:5432
odoo_steg_app_simple  | Warn: Can't find .pfb for face 'Courier'
odoo_steg_app_simple  | 2025-08-21 11:50:32,047 1 INFO ? odoo.addons.base.models.ir_actions_report: Will use the Wkhtmltopdf binary at /usr/local/bin/wkhtmltopdf
odoo_steg_app_simple  | 2025-08-21 11:50:32,056 1 INFO ? odoo.addons.base.models.ir_actions_report: Will use the Wkhtmltoimage binary at /usr/local/bin/wkhtmltoimage
odoo_steg_app_simple  | 2025-08-21 11:50:32,180 1 INFO ? odoo.service.server: HTTP service (werkzeug) running on f2f30f5caee4:8069       
odoo_steg_app_simple  | 2025-08-21 11:50:35,078 1 INFO ? odoo.modules.loading: loading 1 modules...
odoo_steg_app_simple  | 2025-08-21 11:50:35,082 1 INFO ? odoo.modules.loading: 1 modules loaded in 0.00s, 0 queries (+0 extra)
odoo_steg_app_simple  | 2025-08-21 11:50:35,106 1 INFO ? odoo.modules.loading: loading 67 modules...
odoo_steg_app_simple  | 2025-08-21 11:50:35,508 1 INFO ? odoo.modules.loading: 67 modules loaded in 0.40s, 0 queries (+0 extra)
odoo_steg_app_simple  | 2025-08-21 11:50:35,591 1 INFO ? odoo.modules.loading: Modules loaded.
odoo_steg_app_simple  | 2025-08-21 11:50:35,593 1 INFO ? odoo.modules.registry: Registry loaded in 0.526s
odoo_steg_app_simple  | 2025-08-21 11:50:35,594 1 INFO steg_stock odoo.addons.base.models.ir_http: Generating routing map for key None   
odoo_steg_app_simple  | 2025-08-21 11:50:35,612 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:35] "GET /websocket?version=18.0-5 HTTP/1.1" 101 - 20 0.010 0.535
odoo_steg_app_simple  | 2025-08-21 11:50:35,625 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:35] "POST /bus/has_missed_notifications HTTP/1.1" 200 - 2 0.001 0.002
odoo_steg_app_simple  | 2025-08-21 11:50:35,949 1 INFO ? odoo.addons.bus.models.bus: Bus.loop listen imbus on db postgres
odoo_steg_app_simple  | 2025-08-21 11:50:42,774 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:42] "GET /web/database/selector HTTP/1.1" 200 - 8 0.006 1.206
odoo_steg_app_simple  | 2025-08-21 11:50:49,705 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:49] "GET /odoo/apps HTTP/1.1" 200 - 100 0.028 0.921
odoo_steg_app_simple  | 2025-08-21 11:50:49,926 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:49] "GET /bus/websocket_worker_bundle?v=18.0-5 HTTP/1.1" 304 - 4 0.001 0.003
odoo_steg_app_simple  | 2025-08-21 11:50:50,000 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:50] "GET /web/image?model=res.users&field=avatar_128&id=2 HTTP/1.1" 304 - 9 0.005 0.022
odoo_steg_app_simple  | 2025-08-21 11:50:50,006 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:50] "GET /websocket?version=18.0-5 HTTP/1.1" 101 - 1 0.001 0.016
odoo_steg_app_simple  | 2025-08-21 11:50:50,012 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:50] "GET /web/manifest.webmanifest HTTP/1.1" 200 - 9 0.008 0.018
odoo_steg_app_simple  | 2025-08-21 11:50:50,019 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:50] "POST /web/action/load HTTP/1.1" 200 - 12 0.013 0.029
odoo_steg_app_simple  | 2025-08-21 11:50:50,056 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:50] "POST /mail/data HTTP/1.1" 200 - 53 0.035 0.038
odoo_steg_app_simple  | 2025-08-21 11:50:50,076 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:50] "POST /web/dataset/call_kw/ir.module.module/get_views HTTP/1.1" 200 - 56 0.019 0.026
odoo_steg_app_simple  | 2025-08-21 11:50:50,089 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:50] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 1 0.000 0.004
odoo_steg_app_simple  | 2025-08-21 11:50:50,111 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:50] "POST /web/dataset/call_kw/ir.module.module/search_panel_select_range HTTP/1.1" 200 - 52 0.015 0.010
odoo_steg_app_simple  | 2025-08-21 11:50:50,119 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:50] "POST /web/dataset/call_kw/ir.module.module/web_search_read HTTP/1.1" 200 - 4 0.003 0.026
odoo_steg_app_simple  | 2025-08-21 11:50:51,780 1 INFO steg_stock werkzeug: 172.18.0.1 - - [21/Aug/2025 11:50:51] "GET /web/service-worker.js HTTP/1.1" 200 - 1 0.000 0.002
PS H:\Users\GitHub\odoo-18.0> docker exec odoo_steg_app_simple python3 -c "import ast; print('steg_stock_management manifest:'); print(ast.literal_eval(open('/mnt/extra-addons/steg_stock_management/__manifest__.py').read()))"
steg_stock_management manifest:
{'name': 'STEG Stock Management', 'summary': 'Gestion des stocks multi-divisions (STEG)', 'version': '18.0.1.0.0', 'category': 'Inventory/Inventory', 'author': 'STEG', 'website': 'https://steg.tn', 'license': 'LGPL-3', 'depends': ['stock', 'barcodes', 'contacts', 'purchase', 'sale'], 'data': ['security/ir.model.access.csv', 'data/steg_divisions.xml', 'views/steg_division_views.xml', 'views/steg_product_views.xml', 'views/steg_stock_views.xml'], 'installable': True, 'application': True}
PS H:\Users\GitHub\odoo-18.0> docker exec odoo_steg_app_simple python3 -c "import ast; print('steg_barcode manifest:'); print(ast.literal_eval(open('/mnt/extra-addons/steg_barcode/__manifest__.py').read()))"
steg_barcode manifest:
{'name': 'STEG - Codes-barres et Scan', 'version': '18.0.1.0.0', 'category': 'Inventory/Inventory', 'summary': 'Module de codes-barres et scan pour STEG', 'description': '\n        Module Codes-barres STEG\n        ========================\n        \n        Fonctionnalités:\n        - Génération de codes-barres pour les produits STEG\n        - Interface de scan simplifiée\n        - Intégration avec le module STEG Stock Management\n        - Support des formats de codes-barres standards\n        - Scan via webcam ou lecteur dédié\n    ', 'author': 'STEG - Développement Interne', 'website': 'https://www.steg.com.tn', 'license': 'LGPL-3', 'depends': ['base', 'stock', 'product', 'web', 'steg_stock_management'], 'data': ['views/barcode_views.xml', 'views/barcode_templates.xml'], 'assets': {'web.assets_backend': ['steg_barcode/static/src/js/barcode_scanner.js', 'steg_barcode/static/src/css/barcode_scanner.css']}, 'images': ['static/description/icon.png'], 'installable': True, 'application': False, 'auto_install': False, 'sequence': 20}
PS H:\Users\GitHub\odoo-18.0> docker exec odoo_steg_app_simple find /mnt/extra-addons -name "__manifest__.py" -exec dirname {} \;        
find: missing argument to `-exec'
PS H:\Users\GitHub\odoo-18.0> docker exec odoo_steg_app_simple find /mnt/extra-addons -name "__manifest__.py"
/mnt/extra-addons/steg_barcode/__manifest__.py
/mnt/extra-addons/steg_stock_management/__manifest__.py
PS H:\Users\GitHub\odoo-18.0> python force_module_scan.py 
🔍 Vérification des modules STEG dans la base de données...
✅ Commande exécutée avec succès:
Modules STEG trouvÃ©s: 1
- steg_barcode: STEG - Codes-barres et Scan (uninstalled)

ForÃ§age de la mise Ã  jour de la liste des modules...

AprÃ¨s mise Ã  jour - Modules STEG trouvÃ©s: 2
- steg_stock_management: STEG Stock Management (uninstalled)
- steg_barcode: STEG - Codes-barres et Scan (uninstalled)


📋 Instructions:
1. Allez sur http://localhost:8069
2. Connectez-vous
3. Apps → Update Apps List
4. Recherchez 'STEG'
PS H:\Users\GitHub\odoo-18.0> .\steg-addons.ps1 refresh
🔄 Mise à jour du monorepo odoo-18.0...
Already up to date.
✅ Monorepo mis à jour
🔄 Redémarrage du service Odoo (odoo)...
Utilisation de: docker compose -f H:\Users\GitHub\odoo-18.0\docker-compose-simple.yml restart odoo
[+] Restarting 1/1
 ✔ Container odoo_steg_app_simple  Started                                                                                          1.4s 
✅ Service Odoo redémarré
Terminé. Monorepo mis à jour et Odoo redémarré.