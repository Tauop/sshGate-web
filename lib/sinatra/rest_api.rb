module Sinatra
  module RestAPI
    def resources(resource_name, options={})
      resource_name_s = resource_name.to_s

      options = {
        :key      => :id,
        :model    => resource_name_s.capitalize,
        :singular => resource_name_s,
        :plural   => "#{resource_name_s}s",
        :only     => [:index, :new, :show, :edit, :create, :update, :delete]
      }.merge(options)

      # Index
      if options[:only].include?(:index)
        class_eval <<-IndexMeth
          get '/#{options[:plural]}' do
            @#{options[:plural]} = apply_scopes(:#{resource_name}, #{options[:model]}, params).all
            erb :"#{options[:plural]}/index"
          end
        IndexMeth
      end

      # New
      if options[:only].include?(:new)
        class_eval <<-NewMeth
          get '/#{options[:plural]}/new' do
            @#{resource_name} = #{options[:model]}.new
            erb :'#{options[:plural]}/new'
          end
        NewMeth
      end

      # Show
      if options[:only].include?(:show)
        class_eval <<-ShowMeth
          get '/#{options[:plural]}/:#{options[:key]}' do
            @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

            throw :halt, [404, '#{options[:singular].capitalize} not found'] unless @#{resource_name}

            erb :'#{options[:plural]}/show'
          end
        ShowMeth
      end

      # Edit
      if options[:only].include?(:edit)
        class_eval <<-EditMeth
          get '/#{options[:plural]}/edit/:#{options[:key]}' do
            @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

            throw :halt, [404, '#{options[:model].capitalize} not found'] unless @#{resource_name}

            erb :'#{options[:plural]}/edit'
          end
        EditMeth
      end

      # Create
      if options[:only].include?(:create)
        class_eval <<-CreateMeth
          post '/#{options[:plural]}' do
            @#{resource_name} = #{options[:model]}.new(params[:#{resource_name}])
            if @#{resource_name}.save
              redirect "/#{options[:plural]}/\#{@#{resource_name}.#{options[:key]}}", '#{options[:model]} created'
            else
              message = show_errors(@#{resource_name}, 'Error while saving #{options[:singular]}')
              redirect "/#{options[:plural]}/new", message
            end
          end
        CreateMeth
      end

      # Update
      if options[:only].include?(:update)
        class_eval <<-UpdateMeth
          put '/#{options[:plural]}/:#{options[:key]}' do
            @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

            throw :halt, [404, '#{options[:singular].capitalize} not found'] unless @#{resource_name}

            @#{resource_name}.update_attributes(params[:#{resource_name}])
            if @#{resource_name}.save
              redirect "/#{options[:plural]}/\#{@#{resource_name}.#{options[:key]}}", '#{options[:singular].capitalize} updated'
            else
              redirect "/#{options[:plural]}/edit/\#{params[:#{options[:key]}]}", 'Error while updating #{options[:singular]}'
            end
          end
        UpdateMeth
      end

      # Delete
      if options[:only].include?(:delete)
        class_eval <<-DeleteMeth
          delete '/#{options[:plural]}/:#{options[:key]}' do
            @#{resource_name} = #{options[:model]}.find_by_#{options[:key]}(params[:#{options[:key]}])

            throw :halt, [404, '#{options[:singular].capitalize} not found'] unless @#{resource_name}

            @#{resource_name}.destroy
            redirect '/#{options[:plural]}', '#{options[:singular].capitalize} removed'
          end
        DeleteMeth
      end
    end
  end

  # The module registers itself in the Sinatra Application
  register RestAPI
end
