module Sinatra
  module RestAPI
    def resources(resource_name, options={})
      resource_name_s = resource_name.to_s

      options = {
        :key      => :id,
        :model    => resource_name_s.capitalize,
        :plural   => "#{resource_name_s.capitalize}s",
        :singular => resource_name_s
      }.merge(options)

      class_eval <<-EndMeth
        # Index
        get '/#{resource_name}s' do
          @#{resource_name}s = #{options[:model]}.all
          erb :"#{resource_name}s/index"
        end

        # New
        get '/#{resource_name}s/new' do
          @#{resource_name} = #{options[:model]}.new
          erb :'#{resource_name}s/new'
        end

        # Show
        get '/#{resource_name}s/:#{options[:key]}' do
          @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

          throw :halt, [404, '#{options[:singular].capitalize} not found'] unless @#{resource_name}

          erb :'#{resource_name}s/#{resource_name}'
        end

        # Edit
        get '/#{resource_name}s/edit/:#{options[:key]}' do
          @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

          throw :halt, [404, '#{options[:model].capitalize} not found'] unless @#{resource_name}

          erb :'#{resource_name}s/edit'
        end

        # Create
        post '/#{resource_name}s' do
          @#{resource_name} = #{options[:model]}.new(params[:#{resource_name}])
          if @#{resource_name}.save
            redirect "/#{resource_name}s/\#{@#{resource_name}.#{options[:key]}}", '#{options[:model]} created'
          else
            redirect "/#{resource_name}s/new", 'Error while saving #{options[:singular]}'
          end
        end

        # Update
        put '/#{resource_name}s/:#{options[:key]}' do
          @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

          throw :halt, [404, '#{options[:singular].capitalize} not found'] unless @#{resource_name}

          @#{resource_name}.update_attributes(params[:#{resource_name}])
          if @#{resource_name}.save
            redirect "/#{resource_name}s/\#{@#{resource_name}.#{options[:key]}}", '#{options[:singular].capitalize} updated'
          else
            redirect "/#{resource_name}s/edit/\#{params[:#{options[:key]}]}", 'Error while updating #{options[:singular]}'
          end
        end

        # Delete
        delete '/#{resource_name}s/:#{options[:key]}' do
          @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

          throw :halt, [404, '#{options[:singular].capitalize} not found'] unless @#{resource_name}

          @#{resource_name}.destroy
          redirect '/#{resource_name}s', '#{options[:singular].capitalize} removed'
        end
      EndMeth
    end
  end

  register RestAPI
end