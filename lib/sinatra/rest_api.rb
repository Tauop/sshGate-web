module Sinatra
  module RestAPI
    def resources(model_name, options={})
      class_name = model_name.to_s.capitalize

      class_eval <<-EndMeth
        # Index
        get '/#{model_name}s' do
          @#{model_name}s = #{class_name}.all
          erb :"#{model_name}s/index"
        end

        # New
        get '/#{model_name}s/new' do
          @#{model_name} = #{class_name}.new
          erb :'#{model_name}s/new'
        end

        # Show
        get '/#{model_name}s/:name' do
          @#{model_name} = #{class_name}.find_by_name(params[:name])

          throw :halt, [404, '#{class_name} not found'] unless @#{model_name}

          erb :'#{model_name}s/#{model_name}'
        end

        # Edit
        get '/#{model_name}s/edit/:name' do
          @#{model_name} = #{class_name}.find_by_name(params[:name])

          throw :halt, [404, '#{class_name} not found'] unless @#{model_name}

          erb :'#{model_name}s/edit'
        end

        # Create
        post '/#{model_name}s' do
          @#{model_name} = #{class_name}.new(params[:#{model_name}])
          if @#{model_name}.save
            redirect "/#{model_name}s/\#{@#{model_name}.name}", '#{class_name} created'
          else
            redirect "/#{model_name}s/new", 'Error while saving #{class_name}'
          end
        end

        # Update
        put '/#{model_name}s/:name' do
          @#{model_name} = #{class_name}.find_by_name(params[:name])

          throw :halt, [404, '#{class_name} not found'] unless @#{model_name}

          @#{model_name}.update_attributes(params[:#{model_name}])
          if @#{model_name}.save
            redirect "/#{model_name}s/\#{@#{model_name}.name}", '#{class_name} updated'
          else
            redirect "/#{model_name}s/edit/\#{params[:name]}", 'Error while updating #{class_name}'
          end
        end

        # Delete
        delete '/#{model_name}s/:name' do
          @#{model_name} = #{class_name}.find_by_name(params[:name])

          throw :halt, [404, '#{class_name} not found'] unless @#{model_name}

          @#{model_name}.destroy
          redirect '/#{model_name}s', '#{class_name} removed'
        end
      EndMeth
    end
  end

  register RestAPI
end