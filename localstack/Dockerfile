FROM localstack/localstack:1.4

RUN mkdir -p /tmp/app

WORKDIR /tmp/app

# NB: Docker context must be set to root directory of project in order for us to copy the files
COPY ./package*.json ./
COPY ./tsconfig* ./
COPY ./.eslintrc.json ./
COPY ./src ./src

RUN npm ci
RUN npm run build

# Bundle lambdas into single files that can be easily deployed to localstack
RUN ./node_modules/.bin/esbuild ./dist/sandbox-handler.js --bundle --platform=node --outdir=./dist/lambdas

# Reset workdir
