class PagesController < ApplicationController
    layout false
    def not_found
        render file: 'public/404.html', status: :not_found, layout: false
    end
    def index

    end
    def jpegs
        require 'open-uri'
       
        jpegs=jpegs.shuffle
        render :json=>jpegs[0..100]
    end
end
