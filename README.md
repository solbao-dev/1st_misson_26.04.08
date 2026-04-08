# [Codyssey] 미션 1: 개발 워크스테이션 구축

## 1. 프로젝트 개요
본 프로젝트는 코드를 작성하기 전, 개발자로서의 기본기를 다지기 위한 로컬 개발 환경(워크스테이션) 구축을 목표로 합니다. 리눅스 CLI 기반의 파일 및 권한 제어, Docker를 활용한 격리된 컨테이너 환경 구성, 그리고 Git/GitHub를 통한 버전 관리 및 협업 기반 세팅 과정을 직접 수행하고 검증합니다. 

특히 시스템 보안 정책을 고려하여 Docker Desktop 대신 **OrbStack**을 활용해 sudo 권한 없이 컨테이너 환경을 제어하고 실습을 진행했습니다.

---

## 2. 실행 환경
* **OS**: macOS 15.7.4 24G517 
* **Shell/Terminal**: / /bin/zsh
* **Docker Engine**: OrbStack, Docker version 28.5.2 build ecc6942
* **Git Version**: git version 2.53.0

---

## 3. 수행 체크리스트
- [x] 터미널 기본 조작 및 디렉토리 구성 완료
- [x] 디렉토리 및 파일 권한 변경 실습 및 검증 완료
- [x] Docker(OrbStack) 설치 및 데몬 정상 동작 점검 완료
- [x] 기본 컨테이너(`hello-world`, `ubuntu`) 실행 실습 완료
- [x] Dockerfile 작성 및 커스텀 이미지 빌드 완료
- [x] 컨테이너 포트 매핑 설정 및 접속 검증 완료 (2회 이상)
- [x] 바인드 마운트 설정 및 호스트-컨테이너 간 변경 반영 확인
- [x] Docker 볼륨 생성 및 데이터 영속성(Persistence) 검증 완료
- [x] Git 환경 설정 및 GitHub / VSCode 연동 완료

---

## 4. 미션 수행 상세 로그 및 검증

### 4.1 터미널 조작 및 권한 제어
1. 기본 조작 (생성, 복사, 이동, 삭제)
```bash
# 경로 확인
$ pwd
> /Users/greeny10031213

# 디렉토리 생성 및 이동
$ mkdir -p ~/codyssey/practice
$ cd ~/codyssey/practice
> greeny10031213@c3r9s3 practice % pwd
/Users/greeny10031213/codyssey/practice

# 빈 파일 생성 및 확인
$ touch test_file.txt
$ ls -al
> total 0
drwxr-xr-x  3 greeny10031213  greeny10031213  96 Apr  8 21:51 .
drwxr-xr-x  3 greeny10031213  greeny10031213  96 Apr  8 21:25 ..
-rw-r--r--  1 greeny10031213  greeny10031213   0 Apr  8 21:51 test_file.txt
```
* 관찰 내용 요약: `~/`는 내 컴퓨터의 **최상위 홈 디렉토리** 이며, 'mkdir -p'에서 '-p'(parents)옵션은 절대경로를 주든 상대경로를 주든 주어진방식에 맞추어서 중간폴더까지 생성함을 확인하였습니다.
<br>

2.  심화 조작(내용 확인, 복사, 이름변경, 삭제)
```diff
# 파일에 내용 쓰기 및 내용 확인
$ echo "Hello Codyssey solji" > test_file.txt
$ cat test_file.txt
> hello codyssey solji

+ bonus [GUI , 절대경로와 상대경로 , 슬래시 (/)] ☄️💡
greeny10031213@c3r9s3 practice % open test_file.txt
greeny10031213@c3r9s3 practice % cd ~/codyssey
greeny10031213@c3r9s3 codyssey % open test_file.txt
- The file /Users/greeny10031213/codyssey/test_file.txt does not exist.
greeny10031213@c3r9s3 codyssey % open practice/test_file.txt
```
```bash
# 파일 복사 (copy)
$ cp test_file.txt copy_file.txt

# 파일 이름 변경 (move)
$ mv copy_file.txt rename_file.txt

# 파일 삭제 (remove) 및 최종 목록 확인
$rm rename_file.txt$ ls -al
> total 32
drwxr-xr-x  5 greeny10031213  greeny10031213   160 Apr  8 23:14 .
drwxr-xr-x  4 greeny10031213  greeny10031213   128 Apr  8 22:38 ..
-rw-r--r--@ 1 greeny10031213  greeny10031213  6148 Apr  8 23:09 .DS_Store
-rw-r--r--@ 1 greeny10031213  greeny10031213    21 Apr  8 23:12 rename_file.txt
-rw-r--r--@ 1 greeny10031213  greeny10031213    21 Apr  8 22:27 test_file.txt
```

4.  파일 및 디렉토리 권한 변경

> 목적: 파일(r/w/x) 및 디렉토리의 권한을 변경하고 `755`, `644` 등의 표기법에 따른 동작 변화를 확인합니다.
```diff
# 파일 권한 변경 전 확인
$ ls -l test_file.txt
+ -rw-r--r--@ 1 greeny10031213  greeny10031213  21 Apr  8 22:27 test_file.txt

# rwx421 권한 변경
# 755: 소유자 모든 권한 , 읽기실행 / 644: 소유자 읽고 쓰기 , 읽기 / 700: 개인권한
$ chmod 755 test_file.txt
$ ls -l test_file.txt
- -rwxr-xr-x@ 1 greeny10031213  greeny10031213  21 Apr  8 22:27 test_file.txt
```
### 4.2 Docker 기본 점검 (OrbStack)
> 목적: OrbStack을 통한 Docker 데몬 동작 및 버전을 확인합니다.
```diff 
# Docker 버전 확인 📱
$ docker --version
> Docker version 28.5.2, build ecc6942

# 시스템 정보 및 실행 상태 점검
$ docker info
+ 🚢 "선장님(orbstack)뻗음여부 확인가능" Cannot connect to the Docker daemon 🚢
- Client Version:    28.5.2
 Context:    orbstack
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.29.1
    Path:     /Users/greeny10031213/.docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.40.3
    Path:     /Users/greeny10031213/.docker/cli-plugins/docker-compose
Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
- Server Version: 28.5.2
 Storage Driver: overlay2
  Backing Filesystem: btrfs
  Supports d_type: true
  Using metacopy: false
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 CDI spec directories:
  /etc/cdi
  /var/run/cdi
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 1c4457e00facac03ce1d75f7b6777a7a851e5c41
 runc version: d842d7719497cc3b774fd71620278ac9e17710e0
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  cgroupns
 Kernel Version: 6.17.8-orbstack-00308-g8f9c941121b1
- Operating System: OrbStack
 OSType: linux
 Architecture: x86_64
 CPUs: 6
 Total Memory: 15.67GiB
 Name: orbstack
 ID: cf4572cc-6fb8-4085-8270-cc513a4d98a5
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Experimental: false
 Insecure Registries:
  ::1/128
  127.0.0.0/8
 Live Restore Enabled: false
 Product License: Community Engine
 Default Address Pools:
   Base: 192.168.97.0/24, Size: 24
   Base: 192.168.107.0/24, Size: 24
   Base: 192.168.117.0/24, Size: 24
   Base: 192.168.147.0/24, Size: 24
   Base: 192.168.148.0/24, Size: 24
   Base: 192.168.155.0/24, Size: 24
   Base: 192.168.156.0/24, Size: 24
   Base: 192.168.158.0/24, Size: 24
   Base: 192.168.163.0/24, Size: 24
   Base: 192.168.164.0/24, Size: 24
   Base: 192.168.165.0/24, Size: 24
   Base: 192.168.166.0/24, Size: 24
   Base: 192.168.167.0/24, Size: 24
   Base: 192.168.171.0/24, Size: 24
   Base: 192.168.172.0/24, Size: 24
   Base: 192.168.181.0/24, Size: 24
   Base: 192.168.183.0/24, Size: 24
   Base: 192.168.186.0/24, Size: 24
   Base: 192.168.207.0/24, Size: 24
   Base: 192.168.214.0/24, Size: 24
   Base: 192.168.215.0/24, Size: 24
   Base: 192.168.216.0/24, Size: 24
   Base: 192.168.223.0/24, Size: 24
   Base: 192.168.227.0/24, Size: 24
   Base: 192.168.228.0/24, Size: 24
   Base: 192.168.229.0/24, Size: 24
   Base: 192.168.237.0/24, Size: 24
   Base: 192.168.239.0/24, Size: 24
   Base: 192.168.242.0/24, Size: 24
   Base: 192.168.247.0/24, Size: 24
   Base: fd07:b51a:cc66:d000::/56, Size: 64

WARNING: DOCKER_INSECURE_NO_IPTABLES_RAW is set
```
### 4.3 기본 컨테이너 실행 실습
1)  `hello-world` 이미지 실행
```diff
$ docker run hello-world
+ > Unable to find image 'hello-world:latest' locally
+ latest: Pulling from library/hello-world
4f55086f7dd0: Pull complete 
Digest: sha256:452a468a4bf985040037cb6d5392410206e47db9bf5b7278d281f94d1c2d0931
Status: Downloaded newer image for hello-world:latest

+ Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```
2)  `ubuntu` 컨테이너 진입 및 확인
```bash
$ docker run -it ubuntu bash
💡☄️Bonus: typo - error
>docker: Error response from daemon: pull access denied for ubunru, repository does not exist or may require 'docker login': denied: requested access to the resource is denied

root@91b43885ed6d:/# echo "Hello Codyssey!"
>Hello Codyssey!

root@91b43885ed6d:/# ls
>bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr

root@91b43885ed6d:/# exit
>exit
greeny10031213@c3r9s3 ~ %

```
3)  컨테이너 접속 및 유지 , 종료방식의 차이 관찰
```diff
+# 백그라운드에서 돌아가는 박스 생성(-d(detach) 백그라운드실행옵션추가) , 박스확인

$run -itd --name my-box ubuntu bash
>8d6ebc059f860de53d3c38c594a4d863427ac8ead75ced59267d61e3865365da

$docker ps
>CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS         PORTS     NAMES
8d6ebc059f86   ubuntu    "bash"    10 seconds ago   Up 9 seconds             my-box


+#exec으로 새로운 bash(비밀문)열어서 접속하기

$ docker exec -it my-box bash

(컨테이너내부)
root@8d6ebc059f86:/# echo "i am into exec(secret door)"
i am into exec(secret door)
root@8d6ebc059f86:/# exit
exit

(밖으로 빠져나온 뒤 다시 상태 확인)
$ docker ps
>CONTAINER ID   IMAGE     COMMAND   CREATED         STATUS         PORTS     NAMES
8d6ebc059f86   ubuntu    "bash"    2 minutes ago   Up 2 minutes             my-box

+#attach로 메인화면(정문)에 접속하기

$ docker attach my-box
(컨테이너내부)
root@8d6ebc059f86:/# echo " i am into attach(main door)"
 i am into attach(main door)
root@8d6ebc059f86:/# exit
exit

(밖으로 빠져나온 뒤 다시 상태 확인)
$docker ps
>CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED          STATUS                      PORTS     NAMES
8d6ebc059f86   ubuntu        "bash"     4 minutes ago    Exited (0) 24 seconds ago             my-box
91b43885ed6d   ubuntu        "bash"     23 minutes ago   Exited (0) 11 minutes ago             boring_dewdney
203fd0528039   hello-world   "/hello"   28 minutes ago   Exited (0) 28 minutes ago             musing_neumann

* 관찰 내용 요약: `attach`는 실행 중인 컨테이너의 메인 프로세스에 접속하는 것이며, `exec`는 실행 중인 컨테이너에 새로운 프로세스(주로 쉘)를 추가로 실행하여 접속하는 방식임을 확인했습니다.
```
### 4.4 Docker 기본 운영 명령 수행 및 검증
<sub>**목적:** 이미지와 컨테이너의 상태를 조회하고, 로그 및 리소스 모니터링을 통해 운영 상태를 점검합니다.</sub>

**1) 이미지 및 컨테이너 목록 확인**
```bash

# 보유 중인 이미지 목록 확인
$ docker images
>REPOSITORY    TAG       IMAGE ID       CREATED       SIZE
ubuntu        latest    b28307c40a80   5 days ago    78.1MB
hello-world   latest    e2ac70e7319a   2 weeks ago   10.1kB

# 실행 중인 컨테이너 확인
$ docker ps
>CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

# 전체 컨테이너(종료 포함) 확인
$ docker ps -a
>CONTAINER ID   IMAGE         COMMAND    CREATED             STATUS                         PORTS     NAMES
8d6ebc059f86   ubuntu        "bash"     50 minutes ago      Exited (0) 46 minutes ago                my-box
91b43885ed6d   ubuntu        "bash"     About an hour ago   Exited (0) 57 minutes ago                boring_dewdney
203fd0528039   hello-world   "/hello"   About an hour ago   Exited (0) About an hour ago             musing_neumann

```
2) 컨테이너 운영 로그 및 리소스 확인
```bash
# 특정 컨테이너의 실행 로그 확인 (Black box)
$ docker logs my-box
>root@8d6ebc059f86:/# echo " i am into attach(main door)"
 i am into attach(main door)
root@8d6ebc059f86:/# exit
exit

# 컨테이너별 실시간 리소스(CPU/MEM) 사용량 확인
$ docker stats (실시간CCTV) , out : ctrl + C 🎥
$ docker stats --no-stream my-box (폴라로이드 사진)🎇
>CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O     PIDS
8d6ebc059f86   my-box    0.00%     1.355MiB / 15.67GiB   0.01%     1.13kB / 126B   4.43MB / 0B   1

```

### 4.5 커스텀 이미지 제작 및 포트 매핑  

0)src폴더, 브라우저 환영문구, 설명서파일 
```bash
$ cd ~/codyssey/practice  
$ mkdir src  
$ echo '<h1>Hello Solbao Web!</h1>' > src/index.html
$ touch Dockerfile
```

선택한 베이스 이미지: nginx:alpine
커스텀 포인트: Nginx의 기본 index.html을 정적 콘텐츠로 교체하여 나만의 웹 서버 구동

1) Dockerfile 작성
```bash
`FROM` nginx:alpine
`LABEL` org.opencontainers.image.title="solbao-custom-web"
`ENV` APP_ENV=dev
`COPY` src/ /usr/share/nginx/html/
```
2) 빌드 및 컨테이너 실행 (포트 매핑)
```bash
# 이미지 빌드
$ docker build -t my-web:1.0 .
```
<img width="648" height="479" alt="Image" src="https://github.com/user-attachments/assets/fc55f404-2228-4204-a2b2-3ee48396b194" />

```bash
# 포트 매핑을 통한 컨테이너 백그라운드 실행
$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
>9864b991a290b47971316486423da8c682d146813654192882c77e84792c5cec
$ docker run -d -p 8081:80 --name my-web-8081 my-web:1.0
>2fabf307fbc1763cb55668295df2a6939546cdd2b1edca72df59066e90e5baa7
```
3) 접속 증거
* 브라우저에서 `localhost:8080` 및 `localhost:8081` 접속 완료
  
[localhost_8080_접속화면]
<img width="882" height="203" alt="Image" src="https://github.com/user-attachments/assets/64e413a6-292b-404d-b392-1aca4a93b66a" />

[localhost_8081_접속화면]  
<img width="877" height="246" alt="Image" src="https://github.com/user-attachments/assets/8d908009-a7c2-4b44-b86b-5e047368f58b" />

### 4.6 마운트 반영 및 데이터 영속성 검증
1) 바인드 마운트 (Bind Mount)
```bash
# 호스트의 현재 디렉토리를 컨테이너에 마운트하여 실행

$ docker run -d -p 8082:80 -v $(pwd)/src:/usr/share/nginx/html --name bind-test nginx:alpine
>Unable to find image 'nginx:alpine' locally
alpine: Pulling from library/nginx
589002ba0eae: Already exists 
f03becc8ac15: Already exists 
15e759724ff6: Already exists 
ff9f59a6a62e: Already exists 
a71873b303e8: Already exists 
34dfdd2ef1f9: Already exists 
c8a2fa3a88d2: Already exists 
1165b869c51a: Already exists 
Digest: sha256:645eda1c2477aaa9b879f73909b9222c6f19798dd45be6706268d82a661c6e6d
Status: Downloaded newer image for nginx:alpine
a0cc6912219b4f8f5ae5238ce2589083d438a3d157f59086f7695e66a712987c

$ echo '<h1>Bind Mount is Magic!</h1>' > src/index.html
```
<img width="874" height="282" alt="Image" src="https://github.com/user-attachments/assets/f36fcdaa-b7d8-4505-9265-9bc05a217945" />  

* 검증: 호스트의 src/index.html 내용을 수정하고 브라우저를 새로고침 했을 때, 컨테이너 재시작 없이 변경 사항이 즉시 반영됨을 확인했습니다.

2) Docker 볼륨 영속성 (Volume Persistence)
```bash
# 볼륨 생성 및 연결
$ docker volume create solbao-data
$ docker run -d --name vol-test -v solbao-data:/data ubuntu sleep infinity

# 데이터 생성
$ docker exec -it vol-test bash -lc "echo 'Persistence Test' > /data/test.txt"

# 컨테이너 삭제 후 새 컨테이너에 동일 볼륨 연결하여 데이터 확인
$ docker rm -f vol-test
$ docker run -d --name vol-test-2 -v solbao-data:/data ubuntu sleep infinity
$ docker exec -it vol-test-2 bash -lc "cat /data/test.txt"
Persistence Test
```

### 4.7 Git 설정 및 GitHub 연동

1) 로컬 Git 설정
```bash
$ git config --global user.name "Sol-ji Yoon"
$ git config --global user.email "[이메일 주소]"
$ git config --global init.defaultBranch main
$ git config --list
```
2) 연동 증거
![GitHub_연동_완료_화면]([여기에 캡처 이미지 URL을 넣어주세요])

---

## 5. 트러블슈팅 (Troubleshooting)


`Issue 1` : Docker 데몬 연결 실패 (Cannot connect to the Docker daemon)

* 문제: 터미널에서 docker ps 입력 시 데몬에 연결할 수 없다는 에러 발생.

* 원인 가설: 시스템 권한 문제이거나 데몬 애플리케이션이 백그라운드에서 실행되지 않았을 것이다.

* 확인: 환경 구성 시 Docker Desktop 대신 OrbStack을 사용하기로 했으나, 해당 앱을 실행하지 않은 상태였음.

* 해결/대안: OrbStack 애플리케이션을 실행하여 백그라운드에서 Docker 엔진이 구동되도록 한 뒤 명령어를 재실행하여 정상 동작 확인.

`Issue 2` : 포트 충돌 (Bind for 0.0.0.0:8080 failed: port is already allocated)

* 문제: docker run -p 8080:80 ... 명령어 실행 시 포트 할당 에러 발생.

* 원인 가설: 호스트 머신의 8080 포트를 이미 다른 프로세스(또는 기존 컨테이너)가 점유하고 있을 것이다.

* 확인: lsof -i :8080 (또는 docker ps) 명령어로 8080 포트를 사용 중인 기존 컨테이너를 확인.

* 해결/대안: 기존에 실행 중이던 컨테이너를 docker rm -f <컨테이너명>으로 삭제한 후 재실행하거나, 호스트 포트를 8081 등 다른 빈 포트로 변경하여 실행함.

---

## 6. 핵심 개념 요약 (회고)


* 절대 경로 vs 상대 경로: [작성해둔 내용 붙여넣기]

* 파일 권한 (r/w/x) 및 755/644의 의미: [작성해둔 내용 붙여넣기]

* 포트 매핑의 필요성: [작성해둔 내용 붙여넣기]

* Docker 볼륨이란: [작성해둔 내용 붙여넣기]

* Git과 GitHub의 차이: [작성해둔 내용 붙여넣기]
