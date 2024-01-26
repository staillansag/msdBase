# Build d'une image de base MSR

Pour construire une image de base MSR personnalisée, il existe au moins 3 options:
1.  Image de base containers.softwareag.com + webMethods package manager (wpm)
2.  En utilisant les scripts de ce repository: https://github.com/SoftwareAG/sag-unattended-installations
3.  En utilisant l'installateur officiel SAG

On utilisera ici l'option #1 qui s'inspire très largement des pratiques mise en oeuvres dans d'autres plateformes de programmation comme Node.js:
-   On télécharge un runtime de la plateforme (ici le MSR)
-   On enrichit ce runtime avec les packages dont on a besoin, en utilisant un gestionnaire de packages (ici wpm)

Le runtime MSR est disponible sur le registre officiel de conteneurs Software AG: https://containers.softwareag.com
Cette image de base contient très peu de packages, uniquement le socle nécessaire au fonctionnement du runtime.
En partant de cette image produit hautement réutisable, on construit une autre image de base dite de développement, contenant les packages dont on a besoin pour mettre en oeuvre le microservice:
-   les packages webMethods (adaptateur JDBC par exemple), provenant du registre officiel de packages: https://packages.softwareag.com
-   les packages "maison" (par exemple contenant le code d'un framework maison), provenant d'un repository distant Git, voir d'un registre de packages "maison"  

On ajoute également les drivers nécessaire (par exemple les drivers JDBC ou SAP), pour faire en sorte que les développeurs des microservices aient un socle prêt à l'emploi pour réaliser leur travail.  

Cette image de base de développement a également pour vocation de faciliter les patches et les upgrades des produits.  

##  Installation de wpm

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


##  Installation des packages webMethods avec wpm

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

##  Installation des drivers (et autres biliothèques requises)

Les autres dépendances peuvent être injectées de diverses manières, il s'agit toujours de recopier des fichiers ou des répertoires dans l'arborescence de l'image en cours de construction.  
Par exemple pour le driver jdbc Postgres, j'utilise une simple commande curl pour télécharger et copier le driver à l'emplacement souhaité:

```
WORKDIR /opt/softwareag/IntegrationServer/packages/WmJDBCAdapter/code/jars
RUN curl -O https://jdbc.postgresql.org/download/postgresql-42.7.1.jar
WORKDIR /
```

##  Commande de build

Il faut passer un argument dans la commande de build docker pour transmettre le token jwt permettant à wpm de se connecter à https://packages.softwareag.com. La commande de build doit donc prendre cette forme:

```
docker build --build-arg WPM_TOKEN=<token> -t <nom-image> .
```