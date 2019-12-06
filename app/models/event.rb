class Event < ApplicationRecord
    validates :url_id, uniqueness: true
    def self.flyer_formats
        [[600,600],[1920,1080]]
    end
    def acts
        return EventAct.where({:event_id=>self.id})
    end
    def generate_url_id
        if !self.url_id
            url_id=SecureRandom.uuid.split("-")[0]
            url_id="#{url_id}#{rand(0..100)}" if Event.exists?({:url_id=>url_id})
            self.update_attribute(:url_id,url_id)  
        end
    end
    def screenshot(width,height)
        puts "[screenshot] #{width}x#{height}"
        begin
            uuid=SecureRandom.uuid
            command="google-chrome --headless --enable-logging --virtual-time-budget=10000 --window-size=#{width}x#{height} --disable-gpu --no-sandbox --screenshot=\"#{Rails.root.join('public')}/#{uuid}.png\" \"https://tubatuba.net/evento/#{self.url_id}\""
            puts command
            system(command)
            flyer=Flyer.find_or_create_by({width:width,height:height,event_id:self.id})
            flyer.update_attribute(:uuid,uuid)
            return flyer
        rescue => e
            puts e.message
        end
    end
    def screenshot_url
        flyer=Flyer.where({:event_id=>self.id}).order("id DESC").first
        if flyer
            return "https://tubatuba.net/#{flyer.uuid}.png"
        else
            return nil
        end
    end
    def record_video
        require 'rubygems'
        require 'selenium-webdriver'
        
        # Input capabilities
        caps = Selenium::WebDriver::Remote::Capabilities.new
        caps[:browserName] = 'iPhone'
        caps['device'] = 'iPhone 8 Plus'
        caps['realMobile'] = 'true'
        caps['os_version'] = '11'
        caps['name'] = 'Bstack-[Ruby] Sample Test'
        
        
        driver = Selenium::WebDriver.for(:remote,
          :url => "http://localhost:4444/wd/hub",
          :desired_capabilities => caps)
        driver.navigate.to "http://www.google.com"
        element = driver.find_element(:name, 'q')
        element.send_keys "BrowserStack"
        element.submit
        puts driver.title
        driver.quit        

    end
end
