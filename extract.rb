require "active_record"
require "csv"
require "hash_dot"
require "http"

Hash.use_dot_syntax = true

# step 1: put your API key here 
API_KEY = "".freeze

# step 2: put the channels to loop over here
CHANNELS = ["oajwhe896", "Auxasp9543"].freeze

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "twoandahalfdata.sqlite3"
)

unless ActiveRecord::Base.connection.table_exists? 'videos'
  ActiveRecord::Schema.define do
    create_table :videos do |t|
      t.column :video_id, :string, null: false
      t.column :title, :string, null: false
      t.column :description, :string, null: false
      t.column :channel_id, :string, null: false
      t.column :tags, :string
      t.column :published, :datetime
      t.column :views, :integer, null: false
      t.column :likes, :integer, null: false
      t.column :comments, :integer, null: false
      t.column :episode_id, :integer, null: false
    end
    
    create_table :episodes do |t|
      t.column :season, :integer, null: false
      t.column :episode, :integer, null: false
      t.column :title, :string, null: false
    end
  end
end

class Episode < ActiveRecord::Base
  has_many :videos
end

class Video < ActiveRecord::Base
  belongs_to :episode
end

videos = []

# step 3: loop through the channels and get the video lists
CHANNELS.each do |channel|
  # step a: get uploads playlist from channel
  channel_data = HTTP.get("https://youtube.googleapis.com/youtube/v3/channels?part=contentDetails&forUsername=#{channel}&key=#{API_KEY}").parse
  playlist_id = channel_data.items.first.contentDetails.relatedPlaylists.uploads

  # step b: get the entire list of videos
  playlist_data = HTTP.get("https://youtube.googleapis.com/youtube/v3/playlistItems?part=contentDetails&maxResults=50&playlistId=#{playlist_id}&key=#{API_KEY}").parse
  loop do
    playlist_data.items.each do |item|
      videos << item.contentDetails.videoId
    end
    break unless playlist_data.has_key?("nextPageToken")
    playlist_data = HTTP.get("https://youtube.googleapis.com/youtube/v3/playlistItems?part=contentDetails&maxResults=50&pageToken=#{playlist_data.nextPageToken}&playlistId=#{playlist_id}&key=#{API_KEY}").parse
  end
end

# step 4: load the episodes into the database
File.open("episodes.csv").each do |row|
  cols = row.split(",")
  season = cols[0].to_i
  episode = cols[1].to_i
  title = row[8..].strip.downcase.gsub(/[^0-9a-z ]/i, '')
  Episode.create!(season: season, episode: episode, title: title)
end

# step 5: slowly loop through the videos to see if they're actually 2.5 men. otherwise scrap them.
REGEX = /contents":\[\{"runs":\[\{"text":"Two and a Half Men : ([a-zA-z0-9 ,!?'+]*)","navigation/.freeze
n = 0
videos.each do |video|
  #require "pry"
  #binding.pry
  # fetch, parse, and check to see if this is 2.5 men
  n = n + 1
  next if n <= 457
  puts "#{n} of #{videos.count}"
  page = HTTP.get("https://www.youtube.com/watch?v=#{video}").body.to_s
  unless page =~ /comment-item-section/
    puts "failed to get #{video}, am I blocked? sleeping for 10 minutes"
    require "pry"
    binding.pry
    sleep 10*60
    redo
  end

  unless page =~ REGEX
    puts "#{video} is not 2.5 men"
    sleep 15 + rand(10)
    next
  end

  episode_name = page.match(REGEX)[1]

  puts "Found episode #{episode_name} for #{video}"

  video_data = HTTP.get("https://youtube.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=#{video}&key=#{API_KEY}").parse
  item = video_data.items.first
  v = Video.create!(video_id: video, title: item.snippet.title, description: item.snippet.description, channel_id: item.snippet.channelId, tags: item.snippet.tags.to_s, published: Time.parse(item.snippet.publishedAt), views: item.statistics.viewCount, likes: item.statistics.likeCount, comments: item.statistics.commentCount, episode: Episode.find_by_title(episode_name.strip.downcase.gsub(/[^0-9a-z ]/i, '')))
rescue
  require "pry"
  binding.pry
end


