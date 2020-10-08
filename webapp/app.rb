#!/usr/bin/env ruby

require "sinatra"
require "openssl"
require "base64"

configure do
  enable :inline_templates
end

helpers do
  include ERB::Util
end

set :environment, :production

KEY = ["b58b9b9ee2e6ec9441da7f6914359206"].pack("H*")

def encrypt(plaintext)
  plaintext += "\x00" until plaintext.bytesize % 16 == 0
  cipher = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
  cipher.encrypt
  cipher.key = KEY
  cipher.padding = 0
  ciphertext = cipher.update(plaintext) << cipher.final
  return Base64.urlsafe_encode64(ciphertext)
end

def decrypt(base64_ciphertext)
  ciphertext = Base64.urlsafe_decode64(base64_ciphertext)
  cipher = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
  cipher.decrypt
  cipher.key = KEY
  cipher.padding = 0
  plaintext = cipher.update(ciphertext) << cipher.final
  plaintext.gsub!(/\0+\z/,"")
  return plaintext
end

get "/" do
  @title = "Online Shop"
  erb :index
end

post "/purchase" do
  unless params.values.all? {|val| val.is_a? String}
    return "All parameters must be a string"
  end

  if params.values.any? {|val| val.include? ","}
    return "That character is a field separator so you cannot submit that here."
  end
  data = "#{params["cc"]},#{params["month"]},#{params["year"]},UNPAID"
  encrypted_data = encrypt(data)
  redirect to("/processing?data=#{encrypted_data}")
end

get "/processing" do
  encrypted_data = params["data"]
  data = decrypt(encrypted_data)
  cc,month,year,status = data.split(",")
  if status == "PAID"
    redirect to("/payment_succesful?data=#{encrypted_data}")
  end

  @title = "Processing payment..."
  @masked_cc = cc[0..3] + " XXXX XXXX XXXX"
  @month = month
  @year = year
  @status = status
  erb :processing
end

get "/payment_succesful" do
  encrypted_data = params["data"]
  data = decrypt(encrypted_data)
  cc,month,year,status = data.split(",")
  if status != "PAID"
    return "ERROR"
  end

  @title = "Payment was succesfully processed."
  erb :payment_succesful
end


__END__

@@ layout
<!doctype html>
<html>
 <head>
  <title><%= h @title %></title>
 </head>
 <body>
  <h1><%= h @title %></h1>
<%= yield %>
 </body>
</html>

@@ index
<form action="/purchase" method="post">
 Credit Card: <input type="text" name="cc" maxlength="16" /><br />
 Expiration:
 <input type="text" name="month" size="2" maxlength="2" placeholder="MM" />
 &nbsp;/&nbsp;
 <input type="text" name="year" size="4" maxlength="4" placeholder="YYYY" /><br />
 <input type="submit" value="Purchase" />
</form>

@@ processing
We are currently trying to process your payment.<br />
Credit Card: <%= h @masked_cc %><br />
Month: <%= h @month %><br />
Year: <%= h @year %><br />

Current Payment Status: <%= h @status %><br />
<script>
setTimeout(function() {
  location.reload();
},9000);
</script>

@@ payment_succesful
Success! Flag is libctf{ecb_mode_strikes_again}
