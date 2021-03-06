module PostMacros
  
POSTS = [["2009-01-23-first-post.html", { yml_frontmatter: %Q{--- 
layout: post
title: First Post
categories: news
published: true
rss: true
comments: true
tags:
- news
- events
---},
content: %Q{<h1>First post</h1>
<p>Some dummy content with html <a href="http://google.com" target="_blank">link.</a></p>}}],
["2010-01-03-second-post.html", { yml_frontmatter: %Q{--- 
layout: post
title: Second Post
categories: events
published: false
rss: true
comments: true
tags:
- news
- events
- projects
---},
content: %Q{<h1>Second post</h1>
<p>This is another post with some <a href="http://google.com" target="_blank">link.</a></p>}}],
["2011-02-04-third-post.html", { yml_frontmatter: %Q{--- 
layout: post
title: Third Post
categories: projects
published: false
rss: true
comments: true
tags:
- news
---},
content: %Q{<h1>Third post</h1>
<p>This is the third post</p>}}]]

  def create_post
    click_link("New Post")
    fill_in 'Name', :with => 'My new post title'
    fill_in 'Content', :with => '<p>Some dummy content with <a href="http://google.com" target="_blank">link.</a></p>'
    fill_in 'Tags', :with => "tag1, tag2, tag3"
    select '2012', :from => 'post[year]'
    select '6', :from => 'post[month]'
    select '22', :from => 'post[day]'
    select 'photocontest', :from => 'Categories'
    click_button 'Submit'
  end

  def generate_posts(path)
    POSTS.each do |post|
      filename = "#{path}/#{post.first}"
      year = post.first.scan(/\d{4}/).first
      month = post.first.scan(/-\d{2}-/).first.gsub(/-/,"")
      day = post.first.scan(/-{1}\d{2}-{1}\D{1}/).first.gsub(/\D/,"")
      title = post.first.scan(/[a-z]+-{1}+[a-z]*/).first
      publish_path = [Post.published_path, year, month, day, title].join("/").strip
      FileUtils.mkdir_p(publish_path)
      #puts "Creating new post: #{filename}"
      open(filename, 'w') do |file|
        post.last.values.each do |value|
          file.puts "#{value}\n\n"
        end
      end
      File.open([publish_path, "index.html"].join("/"), 'w') {|f| f.write(post.last[:content]) }
    end
  end
  
  def delete_posts(path)
    Dir["#{path}/" + "*.html"].each do |file|
      #puts "Deleting: #{file}"
      File.delete(file)
    end
    Dir.glob([Post.published_path, "**"].join("/")).each { |d| FileUtils.rm_rf d }
  end
  
  def delete_jobs
    Delayed::Job.each {|job| job.destroy}
  end
  
  def new_post(name, date, content, categories, tags)
    @post = Post.new( :name => name, :year => date.split("-").first, :month => date.split("-")[1], :day => date.split("-").last, :content => content, :categories => categories, :tags => tags )
  end
  
end