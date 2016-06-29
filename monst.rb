puts "===== #{Time.now} ====="
require 'open-uri'
require 'nokogiri'
require 'optparse'
require 'yaml'
options={}
OptionParser.new { |o|
  o.banner = "Usage: #{$0} [options]"
  o.on("--threshold=", "threshold") { |v| options[:threshold] = v }
}.parse!(ARGV.dup)
options[:threshold] ||= 15
threshold = options[:threshold].to_i
CONFIG = YAML.load_file('config.yml')

def send_slack
  cmd = "curl -s -X POST --data-urlencode 'payload={\"channel\": \"#monst-gacha\", \"text\": \"<\!here> 今超大だよ\"}' #{CONFIG['slack_api_url']}"
  `#{cmd}`
end

def send_api
  send_slack
end

gacha_doc = Nokogiri.Slop(open('http://monnsutogatya.com').read)
result = gacha_doc.at_css('#a-box table.report-font tr:nth-child(5) font.text-color2').text.to_i > threshold
send_api if result
puts "===== #{Time.now} ====="
