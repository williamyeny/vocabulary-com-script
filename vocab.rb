require 'mechanize'
require 'json'
require 'base64'
require 'caesar_cipher'

mechanize = Mechanize.new

puts "Loading cookies..."
mechanize.cookie_jar.load 'cookies'

nqsecret = "" #next question secret
while true
  begin
    
    beginning_time = Time.new.to_i
    file = mechanize.post("http://www.vocabulary.com/challenge/nextquestion", {
      t: beginning_time,
      secret: nqsecret
    })
      
    #convert file to string to JSON
    data = JSON.parse(file.content)

    #decode adata
    adata_encoded = Base64.decode64(data['result']["adata"])

    #WHAT IN THE FUCK WHY DID THEY USE A CAESAR CIPHER LOL
    caesar = CaesarCipher::Caesar.new 13
    adata = caesar.cipher(adata_encoded)
    
    #method that takes string between two other strings
    #ex: sbm("vocabularydotcom", "vocabulary", "com") => dot
    def sbm str, marker1, marker2
      str[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    end

    #checks for different types of answers
    if adata[3..3] == "c" #picture or mastery question
      puts "Type: accepted answer"
      a = sbm(adata, "\"word\":\"", "\",\"")
    else #mult choice
      a = sbm(adata, "\"nonces\":[\"", "\",\"")
      puts "Type: multiple choice"
    end
    
    
    current_time = Time.new.to_i
    #fuckin SAVE THAT SHIT
    page = mechanize.post("http://www.vocabulary.com/challenge/saveanswer", {
      secret: data['result']["secret"],
      t: current_time,
      rt: current_time - beginning_time + 1000,
      pt: 0,
      a: a.to_s
    })
    puts "SENT! a: #{a}"
    save_data = JSON.parse(page.content)
    nqsecret = save_data['result']["secret"]
  rescue 
  #it returns an error when finishing section, just used exception handling lol hacky af
    puts "YOU FINISHED A SECTION"
  end
  sleep(3) #optional
    
end
