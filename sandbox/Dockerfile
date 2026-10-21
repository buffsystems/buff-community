# Образ песочницы агента Buff Community Edition (#620). Собирается install.sh на вашей машине
# поверх стокового образа Windmill (тот же, что сервер и воркеры: все рантаймы — паритет с
# SaaS) и не публикуется нами: Windmill вы загружаете сами на условиях его авторов. Сверху —
# внутренний docker песочницы, движок Buff и MCP-серверы из образа сервисов, git-lfs.
ARG WINDMILL_IMAGE=ghcr.io/windmill-labs/windmill@sha256:7f67f25ebc8d4f39563bfc0cf3346e9c34e772e5f4eb5caccd8ef713fb11b5bf
ARG BUFF_IMAGE=ghcr.io/buffsystems/buff-community:latest
FROM ${BUFF_IMAGE} AS buff

FROM ${WINDMILL_IMAGE}
ARG DOCKER_VERSION=5:29.8.2-1~debian.13~trixie
ENV DEBIAN_FRONTEND=noninteractive
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && echo "deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" > /etc/apt/sources.list.d/docker.list \
 && apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends \
      docker-ce="${DOCKER_VERSION}" docker-ce-cli="${DOCKER_VERSION}" containerd.io docker-compose-plugin docker-buildx-plugin iptables git-lfs \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /opt/docker-real && mv /usr/bin/docker /opt/docker-real/docker \
 && git config --system safe.directory '*' && git lfs install --system
COPY --from=buff /usr/local/bin/buff /usr/local/bin/buff
COPY --from=buff /mcp /mcp
# docker-guard на месте бинаря docker (#116): прогон зовёт docker только через стража.
RUN ln -sf /mcp/bin/docker /usr/bin/docker && buff --version && git lfs version
