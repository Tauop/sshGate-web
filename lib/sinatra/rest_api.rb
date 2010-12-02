module Sinatra
  module RestAPI
    def resources(resource_name, options={})
      resource_name_s = resource_name.to_s

      options = {
        :key      => :id,
        :model    => resource_name_s.capitalize,
        :singular => resource_name_s,
        :only     => [:index, :new, :show, :edit, :create, :update, :delete]
      }.merge(options)

      # Index
      if options[:only].include?(:index)
        class_eval <<-IndexMeth
          get '/#{resource_name}s' do
            @#{resource_name}s = #{options[:model]}.all
            erb :"#{resource_name}s/index"
          end
        IndexMeth
      end

      # New
      if options[:only].include?(:new)
        class_eval <<-NewMeth
          get '/#{resource_name}s/new' do
            @#{resource_name} = #{options[:model]}.new
            erb :'#{resource_name}s/new'
          end
        NewMeth
      end

      # Show
      if options[:only].include?(:show)
        class_eval <<-ShowMeth
          get '/#{resource_name}s/:#{options[:key]}' do
            @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

            throw :halt, [404, '#{options[:singular].capitalize} not found'] unless @#{resource_name}

            erb :'#{resource_name}s/show'
          end
        ShowMeth
      end

      # Edit
      if options[:only].include?(:edit)
        class_eval <<-EditMeth
          get '/#{resource_name}s/edit/:#{options[:key]}' do
            @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

            throw :halt, [404, '#{options[:model].capitalize} not found'] unless @#{resource_name}

            erb :'#{resource_name}s/edit'
          end
        EditMeth
      end

      # Create
      if options[:only].include?(:create)
        class_eval <<-CreateMeth
          post '/#{resource_name}s' do
            @#{resource_name} = #{options[:model]}.new(params[:#{resource_name}])
            if @#{resource_name}.save
              redirect "/#{resource_name}s/\#{@#{resource_name}.#{options[:key]}}", '#{options[:model]} created'
            else
              message = show_errors(@#{resource_name}, 'Error while saving #{options[:singular]}')
              redirect "/#{resource_name}s/new", message
            end
          end
        CreateMeth
      end

      # Update
      if options[:only].include?(:update)
        class_eval <<-UpdateMeth
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
        UpdateMeth
      end

      # Delete
      if options[:only].include?(:delete)
        class_eval <<-DeleteMeth
          delete '/#{resource_name}s/:#{options[:key]}' do
            @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

            throw :halt, [404, '#{options[:singular].capitalize} not found'] unless @#{resource_name}

            @#{resource_name}.destroy
            redirect '/#{resource_name}s', '#{options[:singular].capitalize} removed'
          end
        DeleteMeth
      end
    end
  end

  # The module registers itself in the Sinatra Application
  register RestAPI
end
