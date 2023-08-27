FROM code.harton.nz/james/dev-container/elixir:latest

ARG USERNAME=vscode
USER ${USERNAME}
ENV HOME=/home/${USERNAME}

COPY .tool-versions /workspace/

WORKDIR /workspace/

RUN asdf_install

ARG HEX_API_KEY
RUN asdf mix local.rebar --force
RUN asdf mix local.hex --force

ENV ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_path '\"/var/tmp/history/erlang.history\"'"

COPY .env* mix.* /workspace/

RUN /bin/bash -c 'if [ -e .envrc ]; then /usr/bin/direnv allow; fi'

RUN asdf mix deps.get
