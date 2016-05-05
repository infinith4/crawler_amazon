# coding: utf-8
require 'open-uri'
require 'mechanize'
require 'kconv'

agent = Mechanize.new
agent.user_agent = 'Mac Safari'

url = 'https://www.amazon.co.jp/ap/signin?_encoding=UTF8&openid.assoc_handle=jpflex&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.ns.pape=http%3A%2F%2Fspecs.openid.net%2Fextensions%2Fpape%2F1.0&openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.amazon.co.jp%2F%3Ftag%3Dhydraamazonav-22%26hvadid%3D39595899217%26hvpos%3D1t1%26hvexid%3D%26hvnetw%3Dg%26hvrand%3D8895839300291415748%26hvpone%3D%26hvptwo%3D%26hvqmt%3De%26hvdev%3Dc%26ref%3Dnav_custrec_signin'

page = agent.get(url)

login_form = page.forms_with(:name => 'signIn').first
login_form.fields_with(:name => 'email').first.value = ""
login_form.fields_with(:name => 'password').first.value = ""
page2 = login_form.click_button

this_year =2015 #任意の集計開始年
charset = nil
index = 1

url = "https://www.amazon.co.jp/gp/your-account/order-history?opt=ab&digitalOrders=1&unifiedOrders=1&returnTo=&__mk_ja_JP=カタカナ&orderFilter=year-#{this_year}"
puts 'get', url
page = agent.get(url)
puts page.title
has_emphasis = agent.page.search('//a[@class="a-size-medium a-link-emphasis"]')
if !has_emphasis.empty? then
  puts "page1 に未取得のデータがあります。"
end

s = agent.page.body.to_s
File.open("#{this_year}-#{index}.html", "w"){ |f|
  f.puts s
}

while true do
  href = agent.page.search('//ul[@class="a-pagination"]/li[@class="a-last"]/a/@href').text
  puts 'get', 'https://www.amazon.co.jp' + href
  button = agent.page.link_with(:href => href)
  if button == nil then
    break
  end
  page = button.click

  has_emphasis = agent.page.search('//a[@class="a-size-medium a-link-emphasis"]')
  if !has_emphasis.empty? then
    puts "page#{index+1} に未取得のデータがあります。"
  end

  index += 1
  s = agent.page.body.to_s
  File.open("#{this_year}-#{index}.html", "w"){ |f|
    f.puts s
  }
end
