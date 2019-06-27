namespace :crawl do
  desc "A task used for crawling ptt web"
  task :get_post => :environment do
    agent = Mechanize.new

    page = agent.get('https://www.ptt.cc/bbs/Gamesale/index.html')

    # Find all the links on the page that are contained with '[]'
    post_links = page.links.find_all {|link| link.text.include?('[')}

    post_links.reverse_each do |link|
      # outer title
      puts link.text
      # outer date
      puts link.attributes.parent.parent.search("div.date").text
      # outer author
      puts link.attributes.parent.parent.search("div.author").text

    end

  end
end
