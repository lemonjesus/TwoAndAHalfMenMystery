require "active_record"
require "rvg/rvg"
include Magick

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

RVG::dpi = 400
rvg = RVG.new(4.75.in, 2.5.in).viewbox(0,0,475,250) do |image|
  image.background_fill = "white"

  image.text(250, 22, "2.5 Men Clips Per Episode Per Channel").styles(text_anchor: "middle", font_size: 20)

  image.g.translate(0, 20) do |canvas|
    # step 1: make a grid of episodes
    Episode.all.pluck(:season).uniq.sort.each do |season|
      canvas.text(65, season * 16 + 10, "Season #{season}").styles(text_anchor: "end")
      Episode.where(season: season).each do |episode|
        videos = episode.videos
        if videos.empty?
          canvas.rect(10, 10, 65 + 16*episode.episode, season * 16).styles(fill: "grey")
        else
          a = videos.select { |x| x.channel_id == "UCsXeKgMxu1IwU6xkZIbjtnQ" }.count
          o = videos.select { |x| x.channel_id == "UCJJq3vsCOuw4mcI70pwFhfQ" }.count
          if (a > 0 && o > 0)
            canvas.rect(10, 10, 65 + 16*episode.episode, season*16).styles(fill: "#f5654e")
            canvas.polygon(65 + 16*episode.episode, season * 16, 75 + 16*episode.episode, season * 16, 65 + 16*episode.episode, season * 16 + 10).styles(fill: "#1cbbff")
            canvas.text(67.2 + 16*episode.episode, season*16 + 4.1, a.to_s).styles(text_anchor: "middle", font_size: 4)
            canvas.text(72.2 + 16*episode.episode, season*16 + 8.2, o.to_s).styles(text_anchor: "middle", font_size: 4)
          elsif (a > 0 && o == 0)
            canvas.rect(10, 10, 65 + 16*episode.episode, season*16).styles(fill: "#f5654e")
            canvas.text(70 + 16*episode.episode, season*16 + 8, a.to_s).styles(text_anchor: "middle", font_size: 8)
          else
            canvas.rect(10, 10, 65 + 16*episode.episode, season*16).styles(fill: "#1cbbff")
            canvas.text(70 + 16*episode.episode, season*16 + 8, o.to_s).styles(text_anchor: "middle", font_size: 8)
          end
        end
      end
    end
  end

  image.rect(10, 10, 135, 231).styles(fill: "#f5654e")
  image.text(150, 240, "Auxasp9543")
  image.rect(10, 10, 245, 231).styles(fill: "#1cbbff")
  image.text(260, 240, "oajwhe896")
end

rvg.draw.write("visualization.png")
