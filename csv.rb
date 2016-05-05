require 'open-uri'
require 'nokogiri'
require 'csv'
require 'kconv'
require 'date'

this_year =2017 # 集計する年
format = '%Y年%m月%d日'

current_dir = Dir.pwd
dataList = []
num = 0

while true
  num += 1
  filename = "#{this_year}-#{num}.html"
  if ! File.exist?(filename) then
    break
  end

  puts "Loading... #{filename}"
  html = Nokogiri::HTML(File.open(filename))

  orders = html.xpath('//div[@class="a-box-group a-spacing-base order"]')

  orders.each_with_index.map do | row, index |
    if row.respond_to?('xpath') then

      order_number = row.xpath('div[1]/div/div/div/div[2]/div[1]/span[2]').text.strip
      puts "order: #{order_number}"

      date_label = row.xpath('div[1]/div/div/div/div[1]/div/div[1]/div[1]/span[@class="a-color-secondary label"]').text.strip
      date_value = row.xpath('div[1]/div/div/div/div[1]/div/div[1]/div[2]/span[@class="a-color-secondary value"]').text.strip
      date = DateTime.strptime(date_value, format)

      sum_label = row.xpath('div[1]/div/div/div/div[1]/div/div[2]/div[1]/span[@class="a-color-secondary label"]').text.strip
      sum_value = row.xpath('div[1]/div/div/div/div[1]/div/div[2]/div[2]/span[@class="a-color-secondary value"]').text.strip.gsub(/￥ */, "").gsub(/,/, "").to_i

      to_label = row.xpath('div[1]/div/div/div/div[1]/div/div[3]/div[1]/span[@class="a-color-secondary label"]').text.strip
      to_value = row.xpath('div[1]/div/div/div/div[1]/div/div[3]/div[2]/span[@class="a-color-secondary value"]').text.strip

      lefts = row.xpath('.//div[@class="a-fixed-left-grid-inner"]')
      lefts.each do | node |
        title = node.xpath('div[2]/div/a[@class="a-link-normal"]').text.strip
        if title == nil then
          next
        end
        if title.length == 0 then
          title = node.xpath('div[2]/div[1]').text.strip # Androd app
        end

        img = node.xpath('div[1]/div[1]/a/img/@src').text.strip
        author = node.xpath('div[2]/div/span[@class="a-size-small"]').text.strip
        seller = node.xpath('div[2]/div/span[@class="a-size-small a-color-secondary"]').text.strip.gsub(/([\s| |　]+)/," ")
        price = node.xpath('div[2]/div/span[@class="a-size-small a-color-price"]').text.strip.gsub(/￥ */, "").gsub(/,/, "").to_i
        if price == 0 then
          price = sum_value
        end
        ver = node.xpath('div[2]/div/span[@class="a-size-small a-color-secondary a-text-bold"]').text.strip  # Kindle?

        hash = Hash.new
        hash['order'] = order_number
        hash['date'] = date
        hash['title'] = title
        hash['author'] = author
        hash['price'] = price
        hash['ver'] = ver
        hash['img'] = img
        hash['seller'] = seller

        if hash.size > 0 then
          dataList << hash
        end
      end

    end

  end

end

dataList = dataList.sort_by { |hash| hash['date'] }

CSV.open('amazon.csv','wb') do |csv|
  csv << ['date','order', 'title','author','price', 'kindle']

  dataList.each do |hash|
    date = hash['date'].strftime('%Y年%m月%d日')
    order = hash['order']
    title = hash['title']
    author = hash['author']
    kindle = hash['ver']
    price = hash['price']

    csv << [date, order, title, author, price, kindle]
  end

end
