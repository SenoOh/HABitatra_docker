# HABitatra
HABitatra は，グループホーム向けにスマートホームシステムである openHAB のデバイスの管理をサポートするインターフェースである．
本システムは，スマートホームシステムの1つである openHAB のデバイスの管理をサポートするインターフェースである．本システムを用いて openHAB のデバイス設定を担う設定ファイルを一括で作成，変更，削除できる．

"HABitatra"は，"openHAB"，"habitat"，"sinatra" をもとに作られた造語である．
この名前は，openHAB を表す"HAB"と生息地を表す"habitat"，Ruby の Web アプリケーションフレームワークである ”sinatra”を組み合わせたものである．
# Requirements
+ Ruby 3.x
+ Java 17.x
+ openHAB
  + https://www.openhab.org/

# Setup
## openHAB
### docker
+ https://www.openhab.org/docs/installation/docker.html
+ ホスト側の`${PWD}/openhab`をコンテナ側の`/openhab/conf`にマウントさせて起動する
+ 起動後，ブラウザ上で http://localhost:8080 を開くと openHAB の画面が開くので各種初期設定を行う

### HABitatra
#### インストール
1. ダウンロード
```bash
$ git clone https://github.com/SenoOh/HABitatra_docker.git
```
2. コンテナイメージ作成
```bash
$ docker build -t habitatra_docker .
```

## Launch
### HABitatra_docker の管理
#### スクリプトを用いる方法
+ 事前準備
    1. `launch.sh` の `OPENHAB_CONTAINER_NAME` を自分の openHAB のコンテナ名に変更する
1. 起動
```shell
$ ./launch.sh start
```
2. 起動 (バックグラウンドで動作させる場合)
```shell
$ ./launch.sh start -d
```
3. 起動 (ポートを指定する場合)
```shell
$ ./launch.sh start -p 80
```
4. 停止
```shell
$ ./launch.sh stop
```
5. 再起動
```shell
$ ./launch.sh restart -d -p 80
```
6. ステータス確認
```shell
$ ./launch.sh status
```

起動後，ブラウザ上で http://localhost:5678 を開くと HABitatra_docker の画面が開く