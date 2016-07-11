require 'open-uri'
require 'nokogiri'
require 'optparse'
require 'yaml'

CONFIG    = YAML.load_file("#{File.expand_path(File.dirname($0))}/config.yml")
THRESHOLD = ($*[0] || 15).to_i
JUSHIN_TH = 20

def send_slack
  text = <<EOS
<\!here> 今超大だよ！ちなみに
#{@probability.map { |k, v| "#{k} => #{v}%"}.join("\n")}
ね。
EOS
  text.gsub!(/\n/, "\\n")
  cmd = "curl -s -X POST --data-urlencode 'payload={\"channel\": \"#monst-gacha\", \"text\": \"#{text}\"}' #{CONFIG['slack_api_url']}"
  `#{cmd}`
end

def send_api
  send_slack
end

def jushin?
  @gacha_doc.at_css('.event-name').text =~ /獣神祭/
end

@gacha_doc = Nokogiri.Slop(open('http://monnsutogatya.com').read)
@probability = 3.upto(5).each_with_object({}) do |i, h|
  tr  = @gacha_doc.at_css("#a-box table.report-font tr:nth-child(#{i})")
  key = "m#{$1}" if tr.text =~ /([0-9]{1,2})分間/
  h[key.to_sym] = @gacha_doc.at_css("#a-box table.report-font tr:nth-child(#{i}) font.text-color2").text
end
result = @probability[:m5].to_i > (jushin? ? JUSHIN_TH : THRESHOLD)
send_api if result
