FROM rocker/r-ubuntu:20.04

ADD Rprofile.site /usr/lib/R/etc/Rprofile.site

RUN install.r devtools rmarkdown tidyverse gifski \
 && installGithub.r rundel/checklist rundel/parsermd

RUN apt-get update \
 && apt-get install -y pandoc libmagick++-dev

CMD ["bash"]
