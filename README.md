Hasura
======

リンク
------

* [公式](https://hasura.io/)
* Qiita記事
  * [Hasuraがめちゃくちゃ便利だよという話](https://qiita.com/maaz118/items/9e198ea91ad8fc624491)
  * [Hasura（GraphQL Engine）をかじってみる](https://qiita.com/piggydev/items/cc29dfe52570d4e6ba63)
  * [Hasuraで既存のPostgreSQLから爆速でGraphQL APIサーバーを構築する](https://qiita.com/ryo2132/items/999f7e6c8958a52d52d6)


Hasuraって何か
--------------

PostgreSQLのDBからGraphQLのAPIサーバを作ってくれちゃうツール？サービス？らしい。

* [GraphQL 基礎 \| Hasura（GraphQL Engine）をかじってみる](https://qiita.com/piggydev/items/cc29dfe52570d4e6ba63#graphql-%E5%9F%BA%E7%A4%8E)

> * 常に POST を使います。
>   * レスポンスは常に 200 が返されます。
>     * エラーが発生した場合は、errors フィールドにエラー内容が含まれます。
> * CRUD の R（Read）が query で、それ以外は mutation で処理をします。
>   * query はパラレルに実行することが可能です。
> * JSON でやりとりするため、画像は base64 encode する必要があります（ファイルサイズがおおよそ1.4倍になります）。
>   * signedURL 等を使って、クライアントから、直接ファイルストレージにアップロード/ダウンロードするアーキテクチャを検討してもよいかもしれません。


### 出処、ライセンスなど

* オープンソースなのかしら？
  * ⇒Community Editionは無料

できること詳細
--------------

### Webサーバ連携

* ログイン認証/セッションはWebサーバと共用したいはず
  * ⇒調査未完
* （UL/DLなど）GraphQLAPI以外の通信はWebサーバにやらせたいのでは？
  * ⇒無理にAPI分けるよりBase64で同格に扱った方が無難かも
  * ⇒サイズ調整とかサムネイル作成が必要だと別APIが必要


使ってみる
----------

### 環境の準備

元になるPostgreSQLとDBが必要なので、以下のサンプルデータを作りました。
メンバーをプロジェクトにアサインするデータ構造をイメージしています。

簡単なER図は [PlantUML](http://www.plantuml.com/plantuml/png/SoWkIImgAStDuL80WjIyaioIIWKbtzJSfDIYOYK5ns05NnIPWAByhDJa4eXK08gKOt5nPdeUHCQH2opbgw2dLmtaWDW1KBP3QbuAq3u0) で参照できます。
```
@startuml
    entity "Members" AS M
    entity "Projects" AS P
    entity "Assigns" AS A

    M ..{ A
    P ..{ A
@enduml
```

PostgreSQLとHasuraの`docker-compose`ファイルを作ったので、以下のコマンドで環境が立ち上がります。
立ち上がった後、`db/create00.sql`を実行する必要があります。
```
$ docker-compose up
$ docker-compose exec db sh
# psql -U postgres -c 'create database tasks'
# psql -U postgres tasks
# #TODO: exec DDL 'db/create00.sql'
```

### 初期設定とクエリの実行

localhost:8080 にアクセスすると、Hasuraのコンソール画面が表示されます。
Dataタブで「Untracked tables or views」「Untracked foreign-key relationships」にテーブルとリレーションが表示されていて、まだHasuraが参照していない状態です。
「Track All」を選択して、全部参照させました。

APIタブからクエリを投げてみます。
まずはMembersテーブル。
```
query {
  members{
    id
    name
  }
}
```

投入したレコードが全て取得できました。
```json
{
  "data": {
    "members": [
      {
        "id": "43c54050-2017-11ec-86d5-0242ac140002",
        "name": "taro"
      },
      {
        "id": "43c5415e-2017-11ec-86d5-0242ac140002",
        "name": "jiro"
      },
      {
        "id": "43c541c2-2017-11ec-86d5-0242ac140002",
        "name": "sabu"
      }
    ]
  }
}
```

次はMembersに紐づくPorjectsを取得してみます。
```
query {
  members(where: {name: {_eq: "jiro"}}){
    id
    name
    assigns {
      id
      project {
        id
        name
      }
    }
  }
}
```

WHERE句がちょっと不細工ですが、何もせずにAPIが作れてしまうのは凄いです。
```json
{
  "data": {
    "members": [
      {
        "id": "43c5415e-2017-11ec-86d5-0242ac140002",
        "name": "jiro",
        "assigns": [
          {
            "id": "47fa27a8-2017-11ec-86d5-0242ac140002",
            "project": {
              "id": "301368ac-2017-11ec-86d5-0242ac140002",
              "name": "dev-a"
            }
          },
          {
            "id": "48012db4-2017-11ec-86d5-0242ac140002",
            "project": {
              "id": "301369ba-2017-11ec-86d5-0242ac140002",
              "name": "dev-b"
            }
          }
        ]
      }
    ]
  }
}
```

調査
----

> * ログイン認証/セッションはWebサーバと共用したいはず

Hasuraで実運用に耐えるアプリを作る場合、認証の仕組みを確認する必要があると思われます。
GraphQL以外のAPIが不要な場合は、Webサーバとセッションを共有しなくてもよいかもしれませんが、Hasuraを認証済みのログインセッションでのみ利用可能にする必要があると思われます。


* [Authentication & Authorization \| Hasura Dos](https://hasura.io/docs/latest/graphql/core/auth/index.html)

> Authentication is handled outside of Hasura. Hasura delegates authentication and resolution of request headers into session variables to your authentication service (existing or new).

* [認証 \| graphql / hasura](https://hasura.io/learn/ja/graphql/hasura/authentication/)

> このチュートリアルでは、認証プロバイダーを統合する方法について説明します。
> リアルタイムの ToDo アプリは、ログインインターフェースで保護する必要があります。この例では、アイデンティティ/認証プロバイダーとして Auth0 を使います。

[Auth0](https://auth0.com/jp) を使えば簡単にできそうです。
まずはAuth0で試して、その後、自前のプロバイダについて調査する方向で良さそうです。
