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
        post = Post.new
        # outer title
        post.title = link.text

        # outer date
        post_date = link.attributes.parent.parent.search("div.date").text

        # outer author
        post.author = link.attributes.parent.parent.search("div.author").text

        post.url = link.uri

        if TimeDifference.between(Time.parse(post_date), Time.now).in_days > 2
          stop_scan = true
        end

        post_content = link.click
        if post_content.search("div#main-content").text.include?("時間")
          post.created_time = post_content.search("div#main-content//span.article-meta-tag:contains('時間')").first.next.text
        else
          # user modified the head title
          post.created_time = post_content.search("div#main-content").text.match(/時間:(.+)/)[1]
        end

        if post_content.search("span.f2").text.include?("編輯")
          post.updated_time = post_content.search("div#main-content//span.f2:contains('編輯')").last.text.split(",").last
        end

        item_content = post_content.search("div#main-content").text

        # process item content
        if post.title.include?("售")
          puts "-------start-------"
          puts item_content.match(/【物品名稱】[：:]\s*(.+)/)[1]
          puts item_content.match(/【售\s*價】[：:]\D*(\d+)/)[1]
          puts item_content
          puts "-------end-------"
        end

        post.save

      rescue
        puts "***************格式不符！！！*************************"
        puts "#{ap $!.backtrace}"
        puts post.title, "https://www.ptt.cc" + post.url
        # puts item_content
        # puts item_content
        # p item_content
        # raise $!, $!.message
        puts "--------------------------------------"
      end

      scan_url = page.links.find {|link| link.text.include?("上頁")}.uri
    end
  end
end
