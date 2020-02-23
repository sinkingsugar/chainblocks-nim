FROM archlinux/base

RUN pacman -Syu --noconfirm && pacman -S --noconfirm base-devel git curl cmake wget clang ninja boost

ARG USER_ID=1000

RUN useradd -ms /bin/bash -u ${USER_ID} tester

USER tester

ENV CHOOSENIM_CHOOSE_VERSION=devel
RUN wget https://nim-lang.org/choosenim/init.sh
RUN sh init.sh -y

ENV PATH=/home/tester/.nimble/bin:$PATH

WORKDIR /home/tester

COPY --chown=tester ./ /home/tester/test

WORKDIR /home/tester/test

ENV HOME=/home/tester
