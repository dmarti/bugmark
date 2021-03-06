module V1
  class Collections < Grape::API

    http_basic do |email, password|
      @current_user = User.find_by_email(email)
      @current_user && @current_user.valid_password?(password)
    end

    resource :repos do
      desc "Return all repos"
      get "", :root => :repos do
        Repo.all
      end
    end

    resource :rebuild_date do
      desc "Return the system rebuild time"
      get "", :root => :rebuild_date do
        fn = "/tmp/bugm_build_date.txt"
        File.exist?(fn) ? File.read(fn).strip : ""
      end
    end

    resource :issues do
      desc "Return all bugs"
      get "", :root => :issues do
        Issue.all
      end
    end

    resource :offers do
      desc "Return all offers"
      get "", :root => :offers do
        Offer.all
      end
    end

    resource :contracts do
      desc "Return all contracts"
      get "", :root => :contracts do
        Contract.all
      end
    end

    resource :positions do
      desc "Return all positions"
      get "", :root => :positions do
        Position.all
      end
    end

    resource :amendments do
      desc "Return all amendments"
      get "", :root => :amendments do
        Amendment.all
      end
    end

    resource :events do
      desc "Return events",
           is_array: true   ,
           http_codes: [
             { code: 200, message: "Event list", model: Entities::Event}
         ]
      params do
        optional :after, type: Integer, desc: "<cursor> an event-ID", documentation: { example: 10 }
      end
      get do
        if params[:after]
          Event.where('id > ?', params[:after])
        else
          Event.all
        end
      end

      desc "Update an event"
      params do
        requires :id           , type: Integer
        requires :etherscan_url, type: String
      end
      put "", :root => :events do
        el = Event.find(params[:id])
        el.update_attribute(:etherscan_url, params[:etherscan_url])
      end
    end
  end
end
