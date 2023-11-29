# HABitatX
本システムは，スマートホームシステムの1つである openHAB のデバイスの管理をサポートするインターフェースである．本システムを用いて openHAB のデバイス設定を担う設定ファイルを一括で作成，変更，削除できる．これによりスマートホームシステムを当該施設で運用する問題点であるデバイスの一括管理の問題を解決する．

"HABitatX"は，"openHAB"と"habitat"をもとに作られた造語である．
この名前は，openHAB を表す"HAB"と生息地を表す"habitat"，未来への展望を表す”X”を組み合わせたものである．HABitatX は，グループホーム向けにスマートホームシステムである openHAB のデバイスの管理をサポートするインターフェースである．
# Requirements
+ Ruby 3.x
+ Java 17.x
+ openHAB
  + https://www.openhab.org/

# Setup
## openHAB
### Linux
まず、openHAB リポジトリキーをパッケージマネージャーに追加する
```
$ curl -fsSL "https://openhab.jfrog.io/artifactory/api/gpg/key/public" | gpg --dearmor > openhab.gpg
$ sudo mkdir /usr/share/keyrings
```

既に存在している場合がある
```
$ sudo mv openhab.gpg /usr/share/keyrings
$ sudo chmod u=rw,g=r,o=r /usr/share/keyrings/openhab.gpg
```

openHAB が置いてあるリポジトリを追加する

stable 版
```
$ echo 'deb [signed-by=/usr/share/keyrings/openhab.gpg] https://openhab.jfrog.io/artifactory/openhab-linuxpkg stable main' | sudo tee /etc/apt/sources.list.d/openhab.list
```

test 版
```
$ echo 'deb [signed-by=/usr/share/keyrings/openhab.gpg] https://openhab.jfrog.io/artifactory/openhab-linuxpkg testing main' | sudo tee /etc/apt/sources.list.d/openhab.list
```

apt のパッケージリストを更新後，openHAB をインストール
```
$ sudo apt-get update
$ sudo apt-get install openhab
```

openHAB のインストール完了後，下記コマンドを実行して openHAB を起動
```
$ sudo systemctl start openhab.service
$ sudo systemctl status openhab.service
$ sudo systemctl daemon-reload
$ sudo systemctl enable openhab.service
```


初回起動に約15分かかる

起動後，ブラウザ上で http://localhost:8080 を開くと openHAB の画面が開くので各種初期設定を行う


# Usage
## Settings
+ excel/ にスプレッドシートを記述して置く．
+ template/ に ERB を記述して置く．
## Launch
### インストール
1. ダウンロード
```bash
$ git clone https://github.com/SenoOh/HABitatra_docker.git
```
2. コンテナイメージ作成
```bash
$ docker build -t habitatra_docker .
```

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