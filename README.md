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
* 📂 **디렉토리 구조 구성 기준 (재현성):** 홈 디렉토리(`~/`) 하위에 코디세이 전체 학습을 관리할 `codyssey` 폴더를 최상단으로 두고, 그 아래에 각 실습 코드를 격리하여 관리하기 위해 `practice` 하위 디렉토리를 구성하였습니다. 이를 통해 프로젝트 간 파일 충돌을 방지하고 작업 공간을 명확히 분리하는 기준으로 구조를 설계했습니다.
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

* 🔗 **포트 설정 재현성 확보 방안:** `Dockerfile`을 통해 베이스 이미지와 파일 복사 경로를 명시하고, `docker run` 명령어에 호스트 포트(`8080`, `8081`)와 컨테이너 포트(`80`) 매핑 규칙을 명확히 기록하였습니다. 이를 통해 누구든 이 문서의 명령어만 복사/붙여넣기 하면 동일한 웹 서버 환경을 즉각적으로 재현할 수 있도록 정리했습니다.


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
>solbao-data
$ docker run -d --name vol-test -v solbao-data:/data ubuntu sleep infinity
>80183a90dc7de91cd97edafa255f0ee97403082dc5d05e8a30e20b257df1ff16

# 데이터 생성
$ docker exec -it vol-test bash -lc "echo 'Persistence Test' > /data/test.txt"

# 컨테이너 삭제 후 새 컨테이너에 동일 볼륨 연결하여 데이터 확인
$ docker rm -f vol-test
>vol-test

# 새 컨테이너에 동일 볼륨 연결
$ docker run -d --name vol-test-2 -v solbao-data:/data ubuntu sleep infinity
>5da479c4fa6cc8b63076e4aaf5ddff0f0be9297c669ee8534572318778a68ab6

#검증절차(명령+출력)
$ docker exec -it vol-test-2 bash -lc "cat /data/test.txt"
>Persistence Test
```
<img width="652" height="196" alt="image" src="https://github.com/user-attachments/assets/3fb5c8b5-540a-41dd-b7ae-43fe29143c33" />

*검증: 마지막 명령어 (cat /data/test.txt) 입력 시, 터미널 화면에 'Persistence Test' 출력되며 데이터가 영구적으로 보존되고있음을 확인하였습니다.  

*💾 **볼륨 설정 재현성 확보 방안:** 데이터 영속성 테스트를 위해 사용한 호스트의 절대 경로(`$(pwd)/src`)와 도커 볼륨 이름(`solbao-data`), 그리고 마운트 대상 경로(`/usr/share/nginx/html`, `/data`)를 명시적으로 기록하여, 컨테이너가 삭제되더라도 동일한 볼륨 마운트 명령어를 통해 즉시 데이터를 복구하고 환경을 재현할 수 있도록 문서를 구성했습니다.  

### 4.7 Git 설정 및 GitHub 연동 (add -> commit -> pull -> push)

1) 로컬 Git 환경 설정 및 초기화

```bash
# 사용자 이름 및 이메일 설정
$ git config --global user.name 'solbao-dev'
$ git config --global user.email 'dianasjyoon@gmail.com’
$ git config --global init.defaultBranch main
$ git config --list

>credential.helper=osxkeychain
user.name=solbao-dev
user.email=‘dianasjyoon@gmail.com’
init.defaultbranch=main
greeny10031213@c3r9s3 practice %

# 설정 내역 확인
$ git config --list
> credential.helper=osxkeychain
> user.name=solbao-dev
> user.email=dianasjyoon@gmail.com
> init.defaultbranch=main

# 현재 실습 디렉토리(practice)를 Git 저장소로 초기화
$ git init

```

<img width="618" height="129" alt="image" src="https://github.com/user-attachments/assets/64610e03-5645-4989-90da-7b880dde89cb" />  

2) 변경 사항 커밋 및 원격 저장소 동기화 (Push & Pull)
   로컬에서 작업한 도커 파일 및 웹 소스 코드를 스테이징하고, 원격 저장소의 파일과 안전하게 병합한 뒤 최종 업로드합니다.
```bash
# 1. 변경된 모든 파일을 스테이징 영역에 추가 및 커밋
$ git add .
$ git commit -m 'feat: 코디세이 도커 미션 완료'

# 2. GitHub 원격 저장소 주소 연결
$ git remote add origin [https://github.com/solbao-dev/1st_misson_26.04.08.git](https://github.com/solbao-dev/1st_misson_26.04.08.git)

# 3. 원격 저장소에만 존재하는 파일(README.md 등)을 로컬로 안전하게 병합 (충돌 방지)
$ git pull origin main --allow-unrelated-histories --no-edit
> Merge made by the 'ort' strategy.

# 4. 병합된 최종 완성본을 원격 저장소로 업로드(Push)
$ git push -u origin main
> branch 'main' set up to track 'origin/main'.
```

3) 연동 증거
로컬 맥북의 작업물(Dockerfile, src/ 등)과 GitHub 웹에서 먼저 작성되었던 리드미 파일이 덮어쓰기 유실 없이 정상적으로 병합(Merge)되어 원격 저장소에 완벽하게 업로드된 것을 확인했습니다.

[![GitHub_연동_완료_화면](https://github.com/user-attachments/assets/c9f07122-f99b-4f24-81fb-21bc08d3e8dd)](https://github.com/user-attachments/assets/c9f07122-f99b-4f24-81fb-21bc08d3e8dd)
---

## 5. 트러블슈팅 (Troubleshooting)
본 실습을 진행하며 CLI 환경 구축, Docker 데몬 구동 및 컨테이너 제어, Git 연동 과정 등 수행 순서에 따라 발생한 이슈들을 분석하고 해결한 기록입니다.

### [Phase 1: 터미널 기초 및 권한 제어]

**`Issue 1` : 중첩 디렉토리 한 번에 생성 실패 (No such file or directory)**
* **문제:** 하위 폴더까지 한 번에 구성하기 위해 `mkdir codyssey/practice`를 입력했으나 해당 경로를 찾을 수 없다는 에러 발생.
* **원인 가설:** 부모 폴더인 `codyssey`가 아직 만들어지지 않은 상태에서 자식 폴더인 `practice`를 동시에 생성하려고 시도하여 시스템이 경로를 추적하지 못했을 것이다.
* **확인:** `ls` 명령어를 통해 홈 디렉토리에 `codyssey` 폴더가 아직 없음을 파악함.
* **해결 및 대안:** `mkdir` 명령어에 `-p` (parents) 옵션을 추가하여 `mkdir -p codyssey/practice`를 실행함으로써, 중간 단계의 부모 디렉토리가 없더라도 에러 없이 자동으로 함께 생성되도록 조치함.

**`Issue 2` : 엉뚱한 디렉토리로의 미아 현상 (잘못된 상대 경로 이동)**
* **문제:** 부모 폴더로 한 단계 이동하려다 실수로 다른 경로 명령어를 입력하여 작업하던 위치를 완전히 잃어버림.
* **원인 가설:** 현재 위치(`.`)와 상위 디렉토리(`..`)의 상대 경로 개념을 혼동했거나, `cd ../..` 등을 남발하여 시스템의 최상위 루트 디렉토리 근처로 빠졌을 것이다.
* **확인:** `pwd` 명령어를 쳐보니 내가 작업하던 `~/codyssey` 경로가 아닌 엉뚱한 시스템 디렉토리에 위치해 있었음.
* **해결 및 대안:** 터미널에서 길을 잃었을 때는 당황하지 않고 항상 단번에 내 홈 디렉토리로 돌아오는 `cd ~` (또는 그냥 `cd`) 명령어를 사용하여 기준점을 잡은 뒤, 절대 경로(`cd ~/codyssey/practice`)를 입력하여 빠르고 안전하게 원래 작업 공간으로 복귀하는 습관을 들임.

**`Issue 3` : GUI 파일 열기 경로 오류 (The file does not exist)**
* **문제:** 터미널에서 텍스트 파일을 열기 위해 `open test_file.txt` 명령어를 실행했으나 파일이 존재하지 않는다는 에러 발생.
* **원인 가설:** 터미널의 현재 작업 위치(`pwd`)와 열고자 하는 파일이 실제 존재하는 경로가 서로 일치하지 않을 것이다.
* **확인:** `pwd` 명령어로 현재 위치를 확인해 보니, 파일이 있는 `~/codyssey/practice` 디렉토리가 아닌 부모 디렉토리인 `~/codyssey`에 머물러 있었음을 확인함.
* **해결 및 대안:** `cd practice` 명령어로 파일이 존재하는 디렉토리로 직접 이동한 후 다시 실행하거나, 현재 위치에서 상대 경로를 명시하여 `open practice/test_file.txt`로 입력하여 파일을 정상적으로 염.

**`Issue 4` : 파일 내용 덮어쓰기 실수 (리다이렉션 기호 오용)**
* **문제:** `test_file.txt`에 새로운 인사말을 "추가"하려고 `echo "New Text" > test_file.txt`를 실행했으나, 기존에 있던 내용이 모두 지워지고 새 내용만 남음.
* **원인 가설:** 셸의 출력 리다이렉션 기호 중 '덮어쓰기(`>`)'와 '이어쓰기(`>>`)'의 역할을 정확히 숙지하지 못하고 혼용했을 것이다.
* **확인:** `cat test_file.txt`로 확인한 결과 기존 데이터가 완전히 소실된 것을 확인함.
* **해결 및 대안:** 기존 파일 내용을 날리지 않고 텍스트를 보존하며 뒤에 줄 바꿈하여 덧붙일 때는 반드시 이중 기호(`>>`)를 사용해야 함을 숙지하고, `echo "Hello again" >> test_file.txt`를 사용하여 안전하게 데이터를 추가함.

**`Issue 5` : 파일 수정/실행 권한 부족 (Permission denied)**
* **문제:** 특정 파일을 스크립트처럼 실행하거나 내용을 덮어쓰려 할 때 권한 거부(Permission denied) 에러 발생.
* **원인 가설:** 해당 파일이 시스템 보안상 쓰기(Write) 또는 실행(Execute) 권한이 부여되지 않은 읽기 전용 상태일 것이다.
* **확인:** `ls -l` 명령어로 파일 상태를 확인한 결과, 권한이 `-rw-r--r--`(644)로 설정되어 있어 소유자를 제외하고는 쓰기가 불가하며 실행 권한은 누구에게도 없음을 확인함.
* **해결 및 대안:** `chmod 755 파일명` 명령어를 통해 소유자에게 읽기/쓰기/실행 권한(7)을, 그룹과 기타 사용자에게 읽기/실행 권한(5)을 부여(`-rwxr-xr-x`)하여 정상적으로 접근 및 실행이 가능하도록 권한 체계를 수정함.

### [Phase 2: Docker 컨테이너 및 볼륨 제어]

**`Issue 6` : Docker 데몬 연결 실패 (Cannot connect to the Docker daemon)**
* **문제:** 터미널에서 `docker ps` 입력 시 데몬에 연결할 수 없다는 에러 발생.
* **원인 가설:** 호스트 운영체제에서 Docker 엔진(데몬)이 백그라운드 프로세스로 실행되지 않고 있을 것이다.
* **확인:** 시스템 구성 시 Docker Desktop 대신 가벼운 OrbStack을 사용하기로 했으나, 해당 애플리케이션을 구동하지 않은 상태였음을 확인.
* **해결 및 대안:** OrbStack 애플리케이션을 수동으로 실행하여 데몬을 활성화한 후, `docker info` 명령어로 정상 동작 여부 및 상태를 재확인함.

**`Issue 7` : 포트 충돌 (Bind for 0.0.0.0:8080 failed: port is already allocated)**
* **문제:** `docker run -p 8080:80 ...` 명령어 실행 시 포트 할당 에러가 발생하며 컨테이너가 띄워지지 않음.
* **원인 가설:** 호스트 머신의 `8080` 포트를 이미 다른 네트워크 프로세스나 이전 실습에서 백그라운드로 띄워둔 컨테이너가 점유하고 있을 것이다.
* **확인:** `docker ps` 명령어를 통해 현재 실행 중인 컨테이너 목록을 조회하여 `8080` 포트를 선점하고 있는 프로세스를 확인.
* **해결 및 대안:** `docker rm -f <기존 컨테이너명>`으로 점유 중이던 컨테이너를 강제 삭제하여 포트를 반환받거나, 새 컨테이너 실행 시 호스트 포트를 `8081` 등 비어있는 포트로 변경하여 실행함.

**`Issue 8` : Zsh 터미널 특수문자 인식 오류 (event not found)**
* **문제:** 마운트 실습 중 파일에 내용을 쓰기 위해 `echo "<h1>...Magic!</h1>" > src/index.html` 실행 시 `zsh: event not found: </h1>` 에러 발생.
* **원인 가설:** macOS의 기본 셸인 zsh가 쌍따옴표(`""`) 안의 느낌표(`!`)를 단순 문자가 아닌 이전 명령어(History)를 불러오는 특수 기호로 오인하여 해석했을 것이다.
* **확인:** 명령어 문자열 내에 느낌표가 포함되어 셸의 확장(expansion) 기능과 충돌했음을 파악.
* **해결 및 대안:** 쌍따옴표 대신 홑따옴표(`''`)를 사용하여 문자열을 감싸(`echo '<h1>...</h1>'`), zsh가 내부 특수문자를 단순 리터럴(Literal) 문자열로만 처리하도록 강제하여 해결함.

### [Phase 3: Git 및 GitHub 연동]

**`Issue 9` : Git 로컬 저장소 초기화 누락 (fatal: not a git repository)**
* **문제:** 터미널에서 `git add .` 실행 시 해당 에러 메시지 발생.
* **원인 가설:** 현재 작업 중인 로컬 디렉토리(`practice`)가 Git 버전 관리를 추적하기 위한 저장소(Repository)로 선언되지 않았을 것이다.
* **확인:** 디렉토리 내에 숨김 폴더인 `.git` 폴더가 존재하는지 확인한 결과 생성되지 않음.
* **해결 및 대안:** `git init` 명령어를 실행하여 해당 디렉토리에 로컬 Git 저장소를 생성한 후, 파일들을 스테이징(`git add`)함.

**`Issue 10` : 셸 입력 대기 상태 늪 빠짐 (dquote> 프롬프트 무한 반복)**
* **문제:** `git commit -m "..."` 명령어 입력 후 셸이 다음 줄로 넘어가지 않고 `dquote>` 프롬프트만 계속 출력됨.
* **원인 가설:** 명령어 입력 중 쌍따옴표(`"`)를 제대로 닫지 않았거나, 내부 특수문자(느낌표 등) 충돌로 인해 셸이 사용자 입력이 끝나지 않은 것으로 간주하고 계속 대기 중일 것이다.
* **확인:** 이전 명령어 구문에 따옴표 짝이 맞지 않는 것을 확인.
* **해결 및 대안:** `Control + C`를 입력하여 현재 프로세스를 강제 종료(Interrupt)하여 원래 셸 상태로 복귀한 후, 홑따옴표(`''`)를 사용해 명령어를 정확히 재입력함.

**`Issue 11` : GitHub CLI 인증 실패 (Support for password authentication was removed)**
* **문제:** 터미널에서 `git push` 수행 시 GitHub 아이디와 계정 비밀번호를 입력했으나 인증 실패 에러 발생.
* **원인 가설:** GitHub의 보안 정책 변경으로 인해, 외부 CLI 환경에서는 더 이상 계정의 본 비밀번호를 통한 접근을 허용하지 않을 것이다. (특히 소셜 로그인 사용 시 패스워드 부재)
* **확인:** GitHub 공식 문서를 통해 CLI 푸시 작업 시 Personal Access Token(PAT)이 필요함을 확인.
* **해결 및 대안:** GitHub 웹의 `Developer settings`에서 `repo` 권한이 부여된 터미널 전용 토큰(Token)을 발급받아, 비밀번호 입력란에 토큰을 대신 입력하여 인증을 통과함.

**`Issue 12` : 원격 저장소 푸시 거부 및 병합 충돌 (Updates were rejected / divergent branches)**
* **문제:** `git push -u origin main` 실행 시 원격 저장소에 로컬에 없는 데이터가 있다는 이유로 푸시가 거부됨.
* **원인 가설:** GitHub 웹 환경에서 `README.md` 파일을 먼저 생성/수정하여 원격(Remote) 저장소의 타임라인이 로컬(Local)보다 앞서 나갔으며, 이 상태에서 로컬 데이터를 강제로 푸시하면 원격 데이터가 유실될 위험이 있어 Git이 방어했을 것이다.
* **확인:** 에러 메시지의 힌트(`hint: the remote contains work that you do not have locally`)를 통해 양측의 브랜치 타임라인이 분기되었음을 파악.
* **해결 및 대안:** 강제 덮어쓰기(`push -f`) 대신, `git config pull.rebase false`로 안전한 Merge 전략을 설정한 뒤 `git pull origin main --allow-unrelated-histories --no-edit` 명령어를 사용하여 원격의 `README.md`를 로컬로 가져와 평화롭게 병합(동기화)한 후 푸시하여 해결함.

---

## 6. 핵심 개념 요약 (회고)

* **절대 경로 vs 상대 경로:** 절대 경로는 루트(`/`) 또는 홈(`~/`) 디렉토리부터 시작하는 변하지 않는 고유한 전체 주소(예: `/Users/greeny.../practice`)를 의미하며, 상대 경로는 현재 내가 위치한 디렉토리(`.`)를 기준으로 대상을 가리키는 방식(예: `./src`, `../`)입니다.

* **파일 권한 (r/w/x) 및 숫자 표기 규칙(755/644):** 파일은 읽기(r=4), 쓰기(w=2), 실행(x=1) 권한을 가집니다. `755`는 소유자(4+2+1=7: 모든 권한), 그룹(4+1=5: 읽기/실행), 기타(4+1=5: 읽기/실행)를 의미하며, `644`는 소유자에게만 읽기/쓰기(4+2=6) 권한을 주고 나머지는 읽기(4)만 허용하는 가장 기본적인 파일 권한 설정입니다.

* **Docker 이미지와 컨테이너의 차이:** '이미지'는 프로그램 실행에 필요한 모든 파일과 설정을 담아놓은 변하지 않는 '설계도(붕어빵 틀)'이며, '컨테이너'는 이 이미지를 바탕으로 실행되어 실제로 동작하고 있는 격리된 '실행 환경(구워진 붕어빵)'입니다.

* **컨테이너 내부 포트 접속 불가 이유 및 포트 매핑의 필요성:** 컨테이너는 호스트(내 맥북)와 완전히 격리된 자체적인 가상 네트워크 환경을 가집니다. 따라서 외부(브라우저)에서 컨테이너 내부의 `80`번 포트로 직접 접속할 수 없습니다. 이를 해결하기 위해 호스트의 특정 포트(`8080`)로 들어오는 요청을 컨테이너의 내부 포트(`80`)로 연결해 주는 **포트 매핑(`-p 8080:80`)**이 반드시 필요합니다.

* **Docker 볼륨이란:** 컨테이너가 삭제되어도 데이터를 안전하게 보존하기 위해, 도커 엔진이 직접 관리하는 호스트의 독립적인 저장 공간입니다. 컨테이너의 생명주기에 영향을 받지 않고 데이터를 영구 저장(Persistence)할 수 있게 해줍니다.

* **Git과 GitHub의 차이:** Git은 로컬 컴퓨터에서 코드의 변경 이력을 추적하고 버전을 관리해 주는 '버전 관리 프로그램'이며, GitHub는 Git으로 관리되는 프로젝트를 인터넷 클라우드에 올려 백업하고 다른 사람들과 협업할 수 있게 해주는 '온라인 웹 호스팅 서비스'입니다.
