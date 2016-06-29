require 'open-uri'
require 'nokogiri'
require 'optparse'
require 'yaml'

CONFIG    = YAML.load_file("#{File.expand_path(File.dirname($0))}/config.yml")
THRESHOLD = ($*[0] || 15).to_i

def send_slack
  cmd = "curl -s -X POST --data-urlencode 'payload={\"channel\": \"#monst-gacha\", \"text\": \"<\!here> 今超大だよ！ちなみに #{@probability}% ね。 \"}' #{CONFIG['slack_api_url']}"
  `#{cmd}`
end

def send_api
  send_slack
end

gacha_doc = Nokogiri.Slop(open('http://monnsutogatya.com').read)
@probability = gacha_doc.at_css('#a-box table.report-font tr:nth-child(5) font.text-color2').text
result = @probability.to_i > THRESHOLD
send_api if result
