## Emacs, make this -*- mode: sh; -*-

FROM ubuntu:noble

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rocker-org/r-ubuntu" \
      org.label-schema.vendor="Rocker Project" \
      maintainer="Dirk Eddelbuettel <edd@debian.org>"

## Set a default user. Available via runtime flag `--user docker` 
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly). 
RUN useradd -s /bin/bash -m docker \
	&& usermod -a -G staff docker

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		software-properties-common \
                dirmngr \
                ed \
                gpg-agent \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
  		gdebi \
        && wget -q -O - https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
                | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc  \
        && add-apt-repository --yes "ppa:marutter/rrutter4.0" \
        #&& add-apt-repository --yes "ppa:c2d4u.team/c2d4u4.0+" \
        && add-apt-repository --yes "ppa:edd/misc"


## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## This was not needed before but we need it now
ENV DEBIAN_FRONTEND noninteractive

## Otherwise timedatectl will get called which leads to 'no systemd' inside Docker
ENV TZ UTC

# Now install R and littler, and create a link for littler in /usr/local/bin
# Default CRAN repo is now set by R itself, and littler knows about it too
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       littler \
 	   r-base \
 	   r-base-dev \
 	   r-recommended \
	   r-cran-docopt \
	&& chown root:staff "/usr/local/lib/R/site-library" \
	&& chmod g+ws "/usr/local/lib/R/site-library" \
  	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
 	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installBioc.r /usr/local/bin/installBioc.r \
 	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
 	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
  	&& ln -s /usr/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r \
 	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
 	&& rm -rf /var/lib/apt/lists/*


## Ours

ADD Rprofile.site /usr/lib/R/etc/Rprofile.site

RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.40/quarto-1.6.40-linux-amd64.deb \
    && DEBIAN_FRONTEND=noninteractive gdebi --n quarto-*-linux-amd64.deb \
    && rm quarto-*-linux-amd64.deb

RUN install.r devtools rmarkdown tidyverse gifski \
 && installGithub.r rundel/checklist rundel/parsermd

RUN apt-get update \
 && apt-get install -y pandoc libmagick++-dev

CMD ["bash"]
