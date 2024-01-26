# Build d'une image de base MSR

Pour construire une image de base MSR personnalisée, il existe au moins 3 options:
1.  Image de base containers.softwareag.com + webMethods package manager (wpm)
2.  En utilisant l'installateur officiel SAG
3.  En utilisant les scripts sag-unattended-installations

##  Image de base containers.softwareag.com + webMethods package manager (wpm)

L'option #1 s'inspire très largement des pratiques mise en oeuvres dans d'autres plateformes de programmation comme Node.js:
-   On télécharge un runtime de la plateforme (ici le MSR)
-   On enrichit ce runtime avec les packages dont on a besoin, en utilisant un gestionnaire de packages (ici wpm)

Le runtime MSR est disponible sur le registre officiel de conteneurs Software AG: https://containers.softwareag.com
Cette image de base contient très peu de packages, uniquement le socle nécessaire au fonctionnement du runtime.
En partant de cette image produit hautement réutisable, on construit une autre image de base dite de développement, contenant les packages dont on a besoin pour mettre en oeuvre le microservice:
-   les packages webMethods (adaptateur JDBC par exemple), provenant du registre officiel de packages: https://packages.softwareag.com
-   les packages "maison" (par exemple contenant le code d'un framework maison), provenant d'un repository distant Git, voir d'un registre de packages "maison"  

On ajoute également les drivers nécessaire (par exemple les drivers JDBC ou SAP), pour faire en sorte que les développeurs des microservices aient un socle prêt à l'emploi pour réaliser leur travail.  

Cette image de base de développement a également pour vocation de faciliter les patches et les upgrades des produits.  

###  Installation de wpm

A partir de la version 11 de webMethods, wpm sera automatiquement inclus dans les images de base des produits.
wpm est utlisable avec les version antérieures (au moins avec la 10.15), mais il faut l'installer sur les images de base produit.
Pour simplifier, je l'ai positionné dans ce repo Git.

Dans le Dockerfile, ajouter les lignes suivantes pour injecter le répertoire wpm dans le build:
```
ADD --chown=sagadmin:sagadmin wpm /opt/softwareag/wpm
RUN chmod u+x /opt/softwareag/wpm/bin/wpm.sh
ENV PATH=/opt/softwareag/wpm/bin:$PATH
```

Voir également cet article sur le Tech forum SAG: https://tech.forums.softwareag.com/t/our-new-delivery-channel-webmethods-package-manager/286873


###  Installation des packages webMethods avec wpm

https://packages.softwareag.com est un registre de packages similaire à https://www.npmjs.com dans le monde Node.js.
Sa vocation est d'être le canal de distribution préférentiel des packages webMethods.

Tout comme on utilise npm (ou yarn) pour installer des packages provenant de https://www.npmjs.com, on utilise wpm pour installer des packages provenant de https://packages.softwareag.com.  

Il faut un token jwt pour se connecter à https://packages.softwareag.com, et wpm offre deux manières de gérer ce token:
-   en argument de la ligne de commande, avec le switch -j
-   en le spécifiant dans le fichier wpm.yml  

C'est la première approche que j'ai choisie, et comme je ne veux pas que ce token soit en dur dans mon Dockerfile, je passe un argument dans mon build docker que l'utilise pour alimenter une variable d'environnement WPM_TOKEN.

```
ARG WPM_TOKEN
ENV WPM_TOKEN=$WPM_TOKEN
```

Ensuite pour récupérer le package du JDBCAdapter et l'injecter dans l'image de base personnalisée:

```
WORKDIR /opt/softwareag/wpm
RUN /opt/softwareag/wpm/bin/wpm.sh install -ws https://packages.softwareag.com -wr softwareag -j $WPM_TOKEN -d /opt/softwareag/IntegrationServer WmJDBCAdapter
WORKDIR /
```

###  Installation des drivers (et autres biliothèques requises)

Les autres dépendances peuvent être injectées de diverses manières, il s'agit toujours de recopier des fichiers ou des répertoires dans l'arborescence de l'image en cours de construction.  
Par exemple pour le driver jdbc Postgres, j'utilise une simple commande curl pour télécharger et copier le driver à l'emplacement souhaité:

```
WORKDIR /opt/softwareag/IntegrationServer/packages/WmJDBCAdapter/code/jars
RUN curl -O https://jdbc.postgresql.org/download/postgresql-42.7.1.jar
WORKDIR /
```

###  Commande de build

Il faut passer un argument dans la commande de build docker pour transmettre le token jwt permettant à wpm de se connecter à https://packages.softwareag.com. La commande de build doit donc prendre cette forme:

```
docker build --build-arg WPM_TOKEN=<token> -t <nom-image> .
```

##  En utilisant l'installer SAG

https://packages.softwareag.com ne contient pas encore tous les packages SAG. Il faut employer cette méthode si les packages dont vous avez besoin ne s'y trouvent pas.

Depuis webMethods 10.11, l'installateur officiel permet de créer des images de base des différents produits.
C'est documenté ici: https://documentation.softwareag.com/a_installer_and_update_manager/wir10-15/webhelp/wir-webhelp/index.html#page/wir-webhelp%2Fto-console_mode_27.html%23

Dans ce qui suit, installer.bin est l'installateur SAG pour l'OS Linux AMD64, téléchargé depuis Empower et renommé.

### Préparation

La première étape des de sélectionner les produits à installer. La liste des produits est très longue, on peut donc s'aider de cette commande:
```
sh installer.bin list artifacts --release 10.15 --username $EMPOWER_USERNAME --password $EMPOWER_PASSWORD --platform LNXAMD64
```

Quelques exemples de code produit :
-   MSC: c'est le socle MSR
-   PIEContainerExternalRDBMS: support des bases de données relationnelles
-   jdbcAdapter: adaptateur JDBC
-   wst: Cloudstreams server

Il faut également fonctionner dans un environnement où Docker (ou une solution équivalente) est installé.

### Création de l'image

Voici la commande à exécuter (ici avec les produits MSC,Monitor,PIEContainerExternalRDBMS,wst,hdfs,jdbcAdapter)
```
sh installer.bin create container-image --name wm-msr:10.15 --release 10.15 --accept-license --products MSC,Monitor,PIEContainerExternalRDBMS,wst,hdfs,jdbcAdapter --admin-password manage --username $EMPOWER_USERNAME --password $EMPOWER_PASSWORD
```

Comme le script télécharge les produits sur Empower, l'exécution dure quelques minutes.
On obtient une image Docker positionnée dans le registre local des images, consultable avec:
```
docker images
```

### Ammélioration de l'image

On peut ensuite supprimer des packages inutiles (par exemple WmWin32, WmAS400), ajouter des drivers, ajuster les autorisations du filesystem pour être compatible avec OpenShift, etc.  

Voici un exemple de build Docker qui utilise un build intermédiaire pour faire toutes ces modifications, et déplace le contenu généré dans une nouvelle image de base.  

```
# Étape 1 : Utilisez un conteneur intermédiaire pour modifier les permissions
FROM wm-msr:10.15 as builder

USER sagadmin

COPY ./drivers/postgresql-42.6.0.jar /opt/softwareag/IntegrationServer/packages/WmJDBCAdapter/code/jars/postgresql-42.6.0.jar
RUN rm -rf /opt/softwareag/IntegrationServer/packages/WmAS400
RUN rm -rf /opt/softwareag/IntegrationServer/packages/WmConsul
RUN rm -rf /opt/softwareag/IntegrationServer/packages/WmGRPC
RUN rm -rf /opt/softwareag/IntegrationServer/packages/WmWin32
RUN rm -rf /opt/softwareag/IntegrationServer/packages/WmRoot/pub/doc/OnlineHelp

USER root

# Autorisations pour OpenShift
RUN chgrp -R root /opt/softwareag && chmod -R g=u /opt/softwareag

# On déplace le tout dans une nouvelle image
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

ENV JAVA_HOME=/opt/softwareag/jvm/jvm/ \
    JRE_HOME=/opt/softwareag/jvm/jvm/ \
    JDK_HOME=/opt/softwareag/jvm/jvm/

RUN microdnf -y update ;\
    microdnf -y install \
        procps \
        shadow-utils \
        findutils \
        ;\
    microdnf clean all ;\
    rm -rf /var/cache/yum ;\
    useradd -u 1724 -m -g 0 -d /opt/softwareag sagadmin

RUN chmod 770 /opt/softwareag
COPY --from=builder /opt/softwareag /opt/softwareag

USER sagadmin

EXPOSE 5555
EXPOSE 9999
EXPOSE 5553

ENTRYPOINT "/bin/bash" "-c" "/opt/softwareag/IntegrationServer/bin/startContainer.sh"
```

##  En utilisant les scripts de sag-unattended-installations

Rendez-vous sur https://github.com/SoftwareAG/sag-unattended-installations
Ces scripts sont maintenus par PS, ils s'appuient également sur l'installer SAG mais avec une mise en oeuvre différente. Peut-être un peu plus complexe, mais à recommander dès lors qu'on veut des images très optimisées.  

Là également, il faut prévoir une étape supplémentaire pour ajouter les drivers ou modifier les autorisation pour OpenShift (comme pour l'installer SAG.)