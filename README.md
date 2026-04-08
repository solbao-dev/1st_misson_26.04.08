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

+ bonus [GUI , 절대경로와 상대경로 , 슬래시 (/)] ☄️
greeny10031213@c3r9s3 practice % open test_file.txt
greeny10031213@c3r9s3 practice % cd ~/codyssey
greeny10031213@c3r9s3 codyssey % open test_file.txt
- The file /Users/greeny10031213/codyssey/test_file.txt does not exist.
greeny10031213@c3r9s3 codyssey % open practice/test_file.txt

# 파일 복사 (copy)
$ cp test_file.txt copy_file.txt

# 파일 이름 변경 (move)
$ mv copy_file.txt rename_file.txt

# 파일 삭제 (remove) 및 최종 목록 확인
$rm rename_file.txt$ ls -al
```

4.  파일 및 디렉토리 권한 변경

> 목적: 파일(r/w/x) 및 디렉토리의 권한을 변경하고 `755`, `644` 등의 표기법에 따른 동작 변화를 확인합니다.
```bash
# 파일 권한 변경 전 확인
$ ls -l test_file.txt
-rw-r--r--  1 solbao  staff  0  4 10 10:00 test_file.txt

# 권한 변경 (예: 실행 권한 추가)
$ chmod 755 test_file.txt
$ ls -l test_file.txt
-rwxr-xr-x  1 solbao  staff  0  4 10 10:01 test_file.txt
```
### 4.2 Docker 기본 점검 (OrbStack)
> 목적: OrbStack을 통한 Docker 데몬 동작 및 버전을 확인합니다.
```bash
# Docker 버전 확인
$ docker --version
[여기에 버전 출력 결과 복사, 예: Docker version 24.0.7, build afdd53b]

# 시스템 정보 및 실행 상태 점검
$ docker info
```
### 4.3 기본 컨테이너 실행 실습
1)  `hello-world` 이미지 실행
```bash
$ docker run hello-world
[여기에 hello from docker 출력 결과 일부 복사]
```
2)  `ubuntu` 컨테이너 진입 및 확인
```bash
$ docker run -it ubuntu bash
root@abc12345:/# echo "Hello Codyssey!"
Hello Codyssey!
root@abc12345:/# exit
```
* 관찰 내용 요약: `attach`는 실행 중인 컨테이너의 메인 프로세스에 접속하는 것이며, `exec`는 실행 중인 컨테이너에 새로운 프로세스(주로 쉘)를 추가로 실행하여 접속하는 방식임을 확인했습니다.

### 4.4 커스텀 이미지 제작 및 포트 매핑
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

# 포트 매핑을 통한 컨테이너 백그라운드 실행
$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
$ docker run -d -p 8081:80 --name my-web-8081 my-web:1.0
```
3) 접속 증거
* 브라우저에서 `localhost:8080` 및 `localhost:8081` 접속 완료
![localhost_8080_접속화면]([여기에 깃허브 이슈나 이미지 호스팅에 올린 이미지 URL을 넣어주세요])

### 4.5 마운트 반영 및 데이터 영속성 검증
1) 바인드 마운트 (Bind Mount)
```bash
# 호스트의 현재 디렉토리를 컨테이너에 마운트하여 실행
$ docker run -d -p 8082:80 -v $(pwd)/src:/usr/share/nginx/html --name bind-test nginx:alpine
```
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

### 4.6 Git 설정 및 GitHub 연동

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
