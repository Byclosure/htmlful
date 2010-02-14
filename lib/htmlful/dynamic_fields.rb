module Htmlful
  module DynamicFields
    def _dynamic_fields(form, resource, relationship_name, block1, block2)
      form.inputs :title => relationship_name do
        unless resource.send(relationship_name).empty?
          form.semantic_fields_for(relationship_name) do |sub_form|
            sub_form.inputs do
              block1.call(sub_form)
              concat sub_form.input(:_delete, :as => :boolean, :wrapper_html => {:class => 'remove'}, :input_html => {:class => "checkbox_remove"})
              concat content_tag(:li, link_to(t(:remove_nested_element, :resource_name => t(resource.class.name)), '#', :class => "remove_fieldset"))
            end
          end
        end
        concat content_tag(:div, :class => "new_nested_element") {
          concat content_tag(:div, :class => "nested_inputs") {
            form.inputs do
              form.semantic_fields_for relationship_name, resource.send(relationship_name).build, :child_index => "NEW_RECORD" do |sub_form|
                block2.call(sub_form)
              end
            end
          }
          relationship_i18n_name = resource.class.human_attribute_name(relationship_name).to_s
          concat link_to(t(:remove_nested_element, :resource_name => relationship_i18n_name), '#', :class => "remove_element")
          concat link_to(t(:create_nested_element, :resource_name => relationship_i18n_name), "#", :class => "create_element")
        }
      end
    end

    def dynamic_fields(form, resource, relationship_name, *attributes)
      block1 = lambda do |sub_form|
        sub_object = sub_form.object
        attributes.each do |attribute|
          if is_date(sub_object, attribute)
            concat sub_form.input(attribute, :as => :string, :wrapper_html => {:class => 'datepick'})
          elsif is_document(sub_object, attribute)
            if is_document_empty?(sub_object, attribute)
              concat content_tag(:li, content_tag(:p, t(:no_document)))
            else
              if is_image(sub_object, attribute)
                concat image_tag(sub_form.object.send(attribute).url(:thumb))
              else
                concat content_tag(:li, content_tag(:p, link_to(sub_object.send("#{attribute}_file_name"), sub_object.send(attribute).url)))
              end
            end
          else
            concat sub_form.input(attribute)
          end
        end
      end
      block2 = lambda do |sub_form|
        sub_object = sub_form.object
        attributes.each do |attribute|
          if is_date(sub_object, attribute)
            concat sub_form.input(attribute, :as => :string, :wrapper_html => {:class => 'datepick ignore'})
          else
            concat sub_form.input(attribute) # takes care of everything else
          end
        end
      end
      _dynamic_fields(form, resource, relationship_name, block1, block2)
    end

    def show_dynamic_fields(form, resource, relationship_name, *attributes)
      form.inputs :title => relationship_name do
        if resource.send(relationship_name).empty?
          concat t(:no_resource_name_plural, :resource_name_plural => resource.class.human_name(:count => 2).mb_chars.downcase)
        else
          form.semantic_fields_for(relationship_name) do |sub_form|
            sub_form.inputs do
              attributes.each do |attribute|
                concat show_attribute(sub_form, sub_form.object, attribute)
              end
            end
          end
        end
      end
    end

    def show_attribute(form, resource, attribute)
      if is_date(resource, attribute)
        form.input(attribute, :as => :string, :wrapper_html => {:class => 'datepick'}, :input_html => {:disabled => true})
      elsif is_document(resource, attribute)
        content_tag(:fieldset) do
          content_tag(:legend) do
            content_tag(:label, I18n.t("formtastic.labels.#{resource.class.name.underscore}.#{attribute}"))
          end +
          if is_document_empty?(resource, attribute)
            t(:no_document)
          else
            if is_image(resource, attribute)
              image_tag(resource.send(attribute).url(:thumb))
            else
              link_to(resource.send("#{attribute}_file_name"), resource.send(attribute).url)
            end
          end
        end
      else
        form.input(attribute, :input_html => {:disabled => true})
      end
    end

    def show_subcollection(form, resource, association)
      collection = resource.send(association)
      resource_name_plural = resource.class.reflect_on_association(association.to_sym).klass.human_name(:count => 2)
      content_tag(:label, resource_name_plural) +
      if collection.empty?
        content_tag(:p, I18n.t(:no_resource_name_plural, :resource_name_plural => resource_name_plural.mb_chars.downcase))
      else
        content_tag(:ul, collection.inject("") { |html, sub_resource|
          html + content_tag(:li, link_to(sub_resource.send(form.send(:detect_label_method, [sub_resource])), sub_resource))
          }, :class => "sub-collection")
      end
    end

    protected
    def is_date(resource, attribute)
      col = resource.column_for_attribute(attribute)
      col && col.type == :date
    end

    # taken from formtastic
    @@file_methods = [:file?, :public_filename]
    def is_document(resource, attribute)
      file = resource.send(attribute) if resource.respond_to?(attribute)
      file && @@file_methods.any? { |m| file.respond_to?(m) }
    end
    
    def is_document_empty?(resource, attribute)
      resource.send("#{attribute}_file_name").blank?
    end
    
    # XXX: if image is missing, this will return false because it queries the styles. Find out what we want
    def is_image(resource, attribute)
      file = resource.send(attribute) if resource.respond_to?(attribute)
      is_document(resource, attribute) && file && file.respond_to?(:styles) && !file.styles.blank?
    end
  end
end
