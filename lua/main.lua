-- main.lua --

----------------------------------
-- WiFi Connection Verification --
----------------------------------
tmr.alarm(0, 1000, 1, function()
  if wifi.sta.getip() == nil then
    print("Connecting to AP...\n")
  else
    ip, nm, gw=wifi.sta.getip()
    print("IP Info: \nIP Address: ",ip)
    print("Netmask: ",nm)
    print("Gateway Addr: ",gw,'\n')
    tmr.stop(0)
  end
end)


----------------------
-- Global Variables --
----------------------
gpios={['gpio0']=3,['gpio4']=2,['gpio5']=1,['gpio12']=6,['gpio13']=7,['gpio14']=5,['gpio16']=0}

adc_id=0 -- Not really necessary since there's only 1 ADC...
adc_value=512
io_value=0

----------------
-- GPIO Setup --
----------------
print("Setting Up GPIO...")
for gpio_name, gpio_nr in pairs(gpios) do
  gpio.mode(gpio_nr, gpio.OUTPUT, gpio.PULLUP)
end

----------------
-- Web Server --
----------------
print("Starting Web Server...")
-- Create a server object with 30 second timeout
srv = net.createServer(net.TCP, 30)

-- server listen on 80, 
-- if data received, print data to console,
-- then serve up the website
srv:listen(80,function(conn)
  conn:on("receive", function(conn, payload)
    local buf = "";
    -- print(payload) -- Print data from browser to serial terminal

    -- Parse http header and find method path and variables
    local _, _, method, path, vars = string.find(payload, "([A-Z]+) (.+)?(.+) HTTP");
    if (method == nil) then
      _, _, method, path = string.find(payload, "([A-Z]+) (.+) HTTP");
    end

    -- Write variables into _GET table
    local _GET = {}
    if (vars ~= nil)then
      for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
        _GET[k] = v
      end
    end

    -- Base HTML structure if root is requested
    if (method=='GET') then -- handling get request
      if (path=='/') then
        buf = buf..'HTTP/1.1 200 OK\n\n';
        buf = buf..'<!DOCTYPE HTML>\n';
        buf = buf..'<html lang="en" ng-app=EspIO>\n';
        buf = buf..'<head><meta  content="text/html; charset=utf-8">\n';
        buf = buf..'<meta name="viewport" content="width=device-width, initial-scale=1">';
        buf = buf..'<link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.8/angular.min.js">';
        buf = buf..'<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"'
        buf = buf..' integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">'
        buf = buf..'<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css"'
        buf = buf..' integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">'
        buf = buf..'<script type="text/javascript" src="https://rawgit.com/flofeurstein/esp_io/master/js/app.js"></script>'
        buf = buf..'<script type="text/javascript" src="https://rawgit.com/flofeurstein/esp_io/master/js/directives.js"></script>'
        buf = buf..'<title>ESP8266 IO</title></head>\n';
        buf = buf..'<body><h1>ESP8266 IO!</h1>\n';
        buf = buf..'<div ng-repeat="io in ios">{{ io }}</div>\n';
        buf = buf..'<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>';
        buf = buf..'<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity='
        buf = buf..'"sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>'
        buf = buf..'</body></html>\n';
      elseif (string.find(path,'/ios/')) then -- handling /ios/ as restful api
        local path_string='/ios/'
        local subpath=string.match(path, path_string.."(%w+)/")

        if (subpath==nil) then
          buf = buf..cjson.encode({adc0=path_string..'adc0/', gpio0=path_string..'gpio0/',
                gpio4=path_string..'gpio4/', gpio5=path_string..'gpio5/', gpio12=path_string..'gpio12/', 
                gpio13=path_string..'gpio13/', gpio14=path_string..'gpio14/', gpio16=path_string..'gpio16/'});
        elseif (subpath=='adc0') then
          adc_value = adc.read(adc_id)
          buf = buf..cjson.encode({[path]=adc_value});
        elseif (string.find(subpath,'gpio')) then
          buf = buf..cjson.encode({[path]=gpio.read(gpios[subpath])});
        else
          buf = buf..cjson.encode({});
        end
      else
        buf = buf..cjson.encode({});
      end
    elseif (method=='POST') then -- handling post request
      if (string.find(path,'/ios/')) then
        local subpath=''
        local value_str=''
        local path_string='/ios/'
        subpath, value_str = string.match(path, path_string.."(%w+)/(%w+)/")

        local val=tonumber(value_str)
        -- print('post: '..value_str)
        if (val~=nil and val>0) then
          gpio.write(gpios[subpath], gpio.HIGH);
          -- print('write '..subpath..' high: '..value_str)
        elseif (val~=nil and val<=0) then
          gpio.write(gpios[subpath], gpio.LOW);
          -- print('write '..subpath..' low: '..value_str)
        end
        
      else
        buf = buf..cjson.encode({});
      end
      buf = buf..'HTTP/1.1 301 Moved Permanently\n\n';
      buf = buf..'<html><head><meta http-equiv="refresh" content="0; URL=\'http://10.0.0.226/\'" /></head></html>';
    end

    conn:send(buf);
    conn:on("sent", function(conn) conn:close() collectgarbage() end)
  end)
end)
