#!/bin/bash

set -e

script_path=$(readlink -f "$0")

if [[ ! -x $script_path ]]; then
    echo "Giving execute permission to script..."
    chmod a+x "$script_path" && sleep 1 && printf "%s\n" "Done" && sleep 1
fi

if [[ -z $ENV_FILE ]]; then
    ENV_FILE=".env"
fi

if [[ -r $ENV_FILE ]]; then
    # shellcheck disable=SC2046
    export $(xargs <"$ENV_FILE")
fi

protocol="http"

if [[ $HTTPS == "true" ]]; then
    protocol="https"
fi

menu="
1) docker-dev  : run development server in docker
2) docker-prod : run production server in docker
3) watch       : run go app and watch changes
4) run         : run go app without building
5) start       : run go app build
6) build       : build go app
7) bench       : run benchmarks
8) test        : run tests
9) test-cover  : run tests and show test coverage
10) pprof       : show pgo profile analysis
11) doc-gen     : generate swaggo API docs
12) checkpoint  : create a git checkpoint and push to remote
"

task=$1

if [[ -z $task ]]; then
    printf "\033[1;95m%s\033[94m%s\033[0m%s\n" "Pick a task to run " "(Enter Q to quit)" "$menu"
    printf "\033[1m%s\033[0m" "Enter option: "
    read -r task
fi

while true; do
    case $task in
    "docker-dev" | 1)
        compose_file="compose-dev.yml"
        trap 'test -d .tmp && rm -rf .tmp' EXIT
        ENV_FILE=$ENV_FILE docker compose -f $compose_file down
        ENV_FILE=$ENV_FILE docker compose -f $compose_file up --build
        break
        ;;
    "docker-prod" | 2)
        compose_file="compose-prod.yml"
        ENV_FILE=$ENV_FILE docker compose -f $compose_file down
        ENV_FILE=$ENV_FILE docker compose -f $compose_file up -d --build
        break
        ;;
    "watch" | 3)
        air
        break
        ;;
    "run" | 4)
        go run --race ./cmd/main
        break
        ;;
    "start" | 5)
        { test -f ./bin/main || { echo "executable build file not found" && $script_path build && echo "running build..."$'\n'"" && ./bin/main; }; } && ./bin/main
        break
        ;;
    "build" | 6)
        echo "building app..."
        $(readlink -f "$script_path") doc-gen rm -rf ./bin && CGO_ENABLED=0 go build --trimpath --buildmode=pie -o ./bin/main ./cmd/main
        echo "built app successfully"
        break
        ;;
    "bench" | 7)
        go test --count=2 -v --bench=. ./...
        break
        ;;
    "test" | 8)
        go test --count=2 -v ./...
        break
        ;;
    "test-cover" | 9)
        go test --coverprofile=/tmp/coverage.out ./... && go tool cover --html=/tmp/coverage.out
        break
        ;;
    "pprof" | 10)
        curl -o ./cmd/main/default.pgo "$protocol"://"$HOST":"$PORT"/debug/pprof/profile?seconds=30
        break
        ;;
    "doc-gen" | 11)
        echo "generating swagger API docs..."
        swag init -q -g ./handler/router.go -o ./docs
        echo "done"
        break
        ;;
    "checkpoint" | 12)
        git add . && git commit -m "checkpoint at $(date "+%Y-%m-%dT%H:%M:%S%z")" && git push && echo "checkpoint created and pushed to remote ✅"
        break
        ;;
    *)
        if [[ $task == "q" || $task == "Q" ]]; then
            printf "\033[1;34m%s\033[0m" "Quitting..."
            break
        fi
        printf "\033[1;31m%s\033[0m\n" "Invalid option"
        printf "\033[1m%s \033[0m" "Enter option:"
        read -r task
        ;;
    esac
done
