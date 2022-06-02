# TwoAndAHalfMenMystery
For years, I've been getting recommendations for YouTube videos with random strings as their names. They're all Two and a Half Men clips with seemingly random starts or ends. The titles and descriptions don't seem to mean anything. At first, I thought someone had backed up their TV library to YouTube. So I wanted to see what the coverage was for the entire series.

The channels in question - [Auxasp9543](https://www.youtube.com/user/Auxasp9543) and [oajwhe896](https://www.youtube.com/user/oajwhe896) - have more than just Two and a Half Men uploaded, but I only care about Two and a Half Men because it seems to be the best tagged show on these channels.

## Methodology
I used the YouTube Data API to get information about the videos, and then scraped the actual view page for the episode name that Youtube found (this doesn't come back from the API). I have delays in the loop because I didn't want to get 429s or 403s from YouTube.

I store all of this information in a SQLite database. I manually reviewed it to find patterns, and then wrote a script that would make an image showing the coverage of the series.

## My Findings
1. Only Seasons 1-7 are covered.
2. Not every episode is represented.
3. The majority of episodes are covered by both channels.
4. The episodes were all uploaded on 2010-10-20 over the course of about 5 hours and they were uploaded in chronological order.
5. The videos are tagged with random strings as well.
6. There is not enough video footage to cover entire episodes, so these are just clips and not a complete backup (so far as I can tell).
7. No data in one video links to another video.

## How to Use
I'm not sure what minimum version of Ruby you need, but it should work on any Ruby 3.

1. Install the dependencies with `bundle`. You might also need to install `ghostscript` and ImageMagick for the image generator to work.
2. Get a Google Cloud API key for the YouTube Data API and put it in `API_KEY`
3. Run `extract.rb`
4. Run `analyze.rb`

Now you should have an sqlite3 database and an image showing you the coverage of the series. I've checked in pre-made versions of these.
