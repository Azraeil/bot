namespace :crawl do
  desc "A task used for crawling ptt web"
  task :get_post => :environment do
    agent = Mechanize.new
    scan_url = 'https://www.ptt.cc/bbs/Gamesale/index.html'
    stop_scan = false

    while stop_scan != true
      page = agent.get(scan_url)

      exclude_entries = ["公告", "黑單", "宣導"]
      match_pattern = Regexp.new(exclude_entries.join('|'))

      # Find all the links on the page that are contained with '[]'
      post_links = page.links.find_all do |link|
        link.text.include?('售') && (link.text =~ match_pattern) == nil
      end
      post_links.reverse_each do |link|
        @post = Post.new
        # outer post title
        @post.title = link.text

        # outer post date
        post_date = link.attributes.parent.parent.search("div.date").text

        # outer post author
        @post.author = link.attributes.parent.parent.search("div.author").text

        @post.url = link.uri

        if TimeDifference.between(Time.parse(post_date), Time.now).in_days > 1
          stop_scan = true
        end

        post_page = link.click.search("div#main-content")

        # backup string
        @post.item_content = post_page.text

        # valid data check
        puts "\n-------valid_data check start-------"
        if valid_data_check(@post) == true

          if post_page.search("div#main-content//span.article-meta-tag:contains('時間')").empty? != true
            @post.created_time = post_page.search("div#main-content//span.article-meta-tag:contains('時間')").first.next.text
          else
            # user modified the head title
            @post.created_time = post_page.text.match(/時間:(.+)/)[1]
          end

          if post_page.search("span.f2").text.include?("編輯")
            @post.updated_time = post_page.search("div#main-content//span.f2:contains('編輯')").last.text.split(",").last
          end

          @post.valid_data = true
          puts "valid data~"
          puts @post.item_name, @post.price
        else
          @post.valid_data = false
          puts "invalid data!!!"
          puts post_page.text
        end

        puts @post.title, "https://www.ptt.cc" + @post.url
        puts "-------valid_data check end-------"

        @post.save

      rescue
        puts "*************** rescue start 格式不符！！！ ***************"
        # puts "#{ap $!.backtrace}"
        # puts $!
        puts post_page.text

        raise $!, $!.message
        puts "******************* rescue end *******************"
      end

      scan_url = page.links.find {|link| link.text.include?("上頁")}.uri
    end
  end
end

def valid_data_check(post)
  # must have key words check
  if (post.item_content =~ /(?=.*時間)(?=.*【物品名稱】)(?=.*(?=.*【\s*售\s*　*\s*價\s*】)).*/m) == nil
    puts "key words check false!!!"
    return false
  end

  # process item data
  item_name = post.item_content.match(/【物品名稱】\s*[：:]*\s*(.+)/)[1]
  # puts item_name

  price = post.item_content.match(/(?=.*【\s*售\s*　*\s*價\s*】)\s*[：:]*\D*(\d+)/)[1]
  # puts price

  # multi-items check
  # post title, item name and price check
  exclude_entries = ["\\/", "\\\\", "\\&", "\\+", "\\.", "、", "等", "及", "換", "徵"]
  match_pattern = Regexp.new(exclude_entries.join('|'))

  # 物品名稱, 售價 multi-lines check
  item_name_lines = post.item_content.split("【物品名稱】")[1].split("【")[0].count("\n")
  price_lines = post.item_content.split(/價\s*】/)[1].split("【")[0].count("\n")
  multi_lines_check = true if (item_name_lines + price_lines) > 4

  puts "item_name_lines = #{item_name_lines}, price_lines = #{price_lines}"

  if (post.title =~ match_pattern) != nil ||
    (item_name =~ match_pattern) != nil ||
    price.to_i < 100 ||
    multi_lines_check == true
  then
    puts "exclude_entries, multi-items or invalid price found!!!"
    return false
  else
    post.item_name = item_name
    post.price = price
  end

  return true
end
