FROM python:3.10-slim-bullseye

ARG USER=flatnotes
ARG UID=1000
ARG GID=1000

ARG APP_DIR=/app
ARG DATA_DIR=${APP_DIR}/data

ENV FLATNOTES_PATH=${DATA_DIR}

RUN addgroup \
    --gid $GID \
    ${USER} \
    || echo "Group '${GID}' already exists."

RUN adduser \
    --disabled-password \
    --gecos "" \
    --no-create-home \
    --ingroup ${USER} \
    --uid ${UID} \
    ${USER} \
    || echo "User '${UID}' already exists."

RUN apt update && apt install -y \
      npm \
 && rm -rf /var/lib/apt/lists/* \
 && pip install pipenv

RUN mkdir -p ${DATA_DIR}
WORKDIR ${APP_DIR}

COPY LICENSE Pipfile Pipfile.lock package.json package-lock.json ./
RUN pipenv install --system --deploy --ignore-pipfile && npm ci

COPY flatnotes ./flatnotes
RUN npm run build

RUN chown -R ${UID}:${GID} ${APP_DIR}
USER ${UID}

ENTRYPOINT [ "python", "-m", "uvicorn", "main:app", "--app-dir", "flatnotes", "--host", "0.0.0.0", "--port", "80" ]
