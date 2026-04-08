# [Codyssey] 미션 1: 개발 워크스테이션 구축

## 1. 프로젝트 개요
본 프로젝트는 코드를 작성하기 전, 개발자로서의 기본기를 다지기 위한 로컬 개발 환경(워크스테이션) 구축을 목표로 합니다. 리눅스 CLI 기반의 파일 및 권한 제어, Docker를 활용한 격리된 컨테이너 환경 구성, 그리고 Git/GitHub를 통한 버전 관리 및 협업 기반 세팅 과정을 직접 수행하고 검증합니다. 

특히 시스템 보안 정책을 고려하여 Docker Desktop 대신 **OrbStack**을 활용해 sudo 권한 없이 컨테이너 환경을 제어하고 실습을 진행했습니다.

---

## 2. 실행 환경
* **OS:** [예: macOS Sonoma 14.x / Windows 11 WSL2 Ubuntu 22.04]
* **Shell / Terminal:** [예: zsh / bash / iTerm2]
* **Docker Engine:** [예: OrbStack (Docker version 24.x.x)]
* **Git Version:** [예: git version 2.39.3]

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
# 디렉토리 생성 및 이동
$ mkdir -p ~/codyssey/practice
$ cd ~/codyssey/practice

# 빈 파일 생성 및 확인
$ touch test_file.txt
$ ls -alㅍ
```
2.  파일 및 디렉토리 권한 변경

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
