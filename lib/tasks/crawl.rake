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
        link.text.include?('[') && (link.text =~ match_pattern) == nil
      end

      post_links.reverse_each do |link|
        # outer title
        puts link.text
        # outer date
        post_date = link.attributes.parent.parent.search("div.date").text
        puts post_date
        # outer author
        puts link.attributes.parent.parent.search("div.author").text
        if TimeDifference.between(Time.parse(post_date), Time.now).in_weeks > 2
          stop_scan = true
        end

      end
      puts "end"
      scan_url = page.links.find {|link| link.text.include?("上頁")}.uri
    end
  end
end
