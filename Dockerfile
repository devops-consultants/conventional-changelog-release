FROM node:24.1.0-alpine3.20

RUN apk add --update --no-cache bash git curl  && apk upgrade

# Install the Bitbucket Pipes Toolkit
RUN wget --no-verbose -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/0.6.0/common.sh

COPY LICENSE pipe.yml README.md /

RUN npm install -g conventional-changelog-cli conventional-recommended-bump conventional-changelog-conventionalcommits git-semver-tags

# Set the default directory for the safe command
RUN git config --global --add safe.directory /opt/atlassian/pipelines/agent/build

COPY pipe.sh config.cjs /
RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
