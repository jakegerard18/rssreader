require 'rss'
require 'open-uri'
require 'colorize'
URL_REGEX = /^(https:\/\/|http:\/\/)w?w?w?.*[.][a-z]{3}.*$/

#Adds an RSS feed subscription to the 'subscriptions.txt' file so the feed can be read.
def add_subscription
 puts "Enter the URL of the subscription you would like to add (C = cancel):"
 url = gets.chomp
 if url.upcase == 'C'
  menu
 elsif url =~ URL_REGEX
  file = File.open("./subscriptions.txt", 'a')
  file.puts(url)
  file.close
  puts "#{url} added to feed!".light_green
 else
  puts "Please enter a valid URL.".red
  add_subscription
 end
end

#Displays all URLs in 'subscriptions.txt' file.
def show_subscriptions
  if File.exist?("./subscriptions.txt")
    puts "\nSubscriptions:"
    File.foreach("./subscriptions.txt") {|sub| puts "#{sub}".magenta}
  else
    puts "No current subscriptions. Enter 'A' to add a subscription or 'C' to cancel.".red
    input = gets.chomp
    if input == 'A'
      add_subscription
    elsif input == 'C'
      menu
    end
  end
end

#Removes an RSS feed subscription from the 'subscriptions.txt' file.
def remove_subscription
  feeds = File.readlines('./subscriptions.txt')
  puts "Select the number of the feed you would like to remove:".green
  feeds.each_with_index do |feed, index|
    puts "#{index + 1} => #{feed}".magenta
  end

  index_to_remove = gets.chomp
  feeds.delete_at(index_to_remove.to_i - 1)
  File.open('./subscriptions.txt', 'w') do |f|
    feeds.each do |feed|
      f.write feed
    end
    f.close
  end
end

#Displays RSS feed.
def show_feed
  if File.exist?("./subscriptions.txt")
    File.foreach("./subscriptions.txt") {|url|
      URI.open(url.chomp) do |rss|
          feed = RSS::Parser.parse(rss)
          puts "\n#{feed.channel.title}".magenta
          feed.items.each do |item|
            puts "    ->#{item.title}".blue
            puts "      Link: #{item.link}".green
          end
        end
    }
  else
    puts "No current subscriptions. Enter 'A' to add a subscription or 'C' to cancel.".red
    input = gets.chomp
    if input == 'A'
      add_subscription
    elsif input == 'C'
      menu
    end
  end
end

#Menu loop method to take user input.
def menu
  input = nil
  while input != 'Q'
    puts "\nEnter an option: D = Display feed, A = Add subscription, S = Display subscriptions, R = Remove subscription, Q = Quit"
    input = gets.chomp
    input.upcase!
    if input == 'A'
      add_subscription
    elsif input == 'D'
      show_feed
    elsif input == 'S'
      show_subscriptions
    elsif input == 'R'
      remove_subscription
    elsif input == 'Q'
      puts "Are you sure you want to quit? Y/N?"
      response = gets.chomp
      response.upcase!
      if response == 'Y'
        return
      else
        input = nil
        next
      end
    end
  end
end

#Main method (first method that runs on program execution).
def main
  puts "Welcome to RSSR (Really Simple Syndication Reader)!"
  menu
end  

main
