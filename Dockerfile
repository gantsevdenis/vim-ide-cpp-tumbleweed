FROM opensuse/tumbleweed
RUN zypper --non-interactive install -y shadow vim cmake python38-devel \
    gcc-c++ git clang-tools ninja autoconf automake python38-pip clang12 \
    gdb
# compiledb *make* based projects, not *cmake*
RUN pip3 install compiledb watchdog
RUN useradd -m docker
ENV HOME=/home/docker
RUN mkdir -p ${HOME}/.vim/bundle
ENV PATH="${HOME}/.local/bin:${PATH}"
ENV TERM=xterm-256color
RUN git clone https://github.com/universal-ctags/ctags.git /home/docker/ctags
RUN git clone https://github.com/VundleVim/Vundle.vim.git /home/docker/.vim/bundle/Vundle.vim

RUN chown -R docker:users ${HOME}
USER docker
WORKDIR  ${HOME}/ctags
RUN ./autogen.sh && ./configure && make -j4

# get all the plugins
COPY vimrc-base ${HOME}/.vimrc
RUN vim +PluginInstall +qall
WORKDIR ${HOME}/.vim/bundle/YouCompleteMe
RUN python3 install.py --clangd-completer

USER root
WORKDIR  ${HOME}/ctags
RUN make install
COPY vimrc-secondary ${HOME}/.vimrc-secondary
RUN chown -R docker:users ${HOME}
USER docker

WORKDIR  ${HOME}
RUN cat $HOME/.vimrc-secondary >> $HOME/.vimrc
CMD bash
# vim-ide-cpp-tumbleweed