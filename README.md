# amazon の注文履歴取得

目的: amazonの注文履歴から特定カテゴリ(本、kindle)の注文データを取得


以下を参考にした：
http://qiita.com/JunSuzukiJapan/items/eed49f67e2f3d562bfec

get.rb, csv.rbはそのまま。

# usage

1. get html

get.rbで
this_year =2015
login_form.fields_with(:name => 'email').first.value = "Amazon登録メールアドレス"
login_form.fields_with(:name => 'password').first.value = "Amazonパスワード"

を指定する。

2. export csv of category
amazon_auto.pl で指定した年の注文データのカテゴリ(books, kindle)の注文データをCSVに出力する。


 