# encoding: UTF-8

require 'sketchup.rb'
require 'json'
require 'rexml/document'

module AtributoInjetor

  extend self

  PLUGIN_ID   = 'atributo_injetor'
  PLUGIN_NAME = 'Atributo Injetor'

  REPOSITORY_PATH =
    File.join(__dir__, 'repository.xml')

  FUNCTIONS_PATH =
    File.join(__dir__, 'functions.xml')

  NATIVE_CATALOG_PATH =
    File.join(__dir__, 'native_catalog.xml')

  @repository_runtime = []
  @collections_runtime = []

  # =========================================================
  # SHOW UI
  # =========================================================

  def show_ui

    if @dialog.nil?

      @dialog = create_dialog

    end

    @dialog.show

    UI.start_timer(0.25, false) {

      begin

        repository_data =
          load_repository_data

        @repository_runtime =
          repository_data[:attributes]

        @collections_runtime =
          repository_data[:collections]

        @dialog.execute_script(
          "window.loadRepository(#{@repository_runtime.to_json})"
        )

        @dialog.execute_script(
          "window.loadCollections(#{@collections_runtime.to_json})"
        )

        inspector =
          inspect_selected_component

        @dialog.execute_script(
          "window.renderInspector(#{inspector.to_json})"
        )

      rescue => e

        puts e.message

      end

    }

  end

  # =========================================================
  # CREATE DIALOG
  # =========================================================

  def create_dialog

    dialog = UI::HtmlDialog.new(
      {
        dialog_title: PLUGIN_NAME,
        preferences_key: PLUGIN_ID,
        scrollable: true,
        resizable: true,
        width: 1180,
        height: 820,
        style: UI::HtmlDialog::STYLE_DIALOG
      }
    )

    dialog.set_file(
      File.join(__dir__, 'ui.html')
    )

    # =========================================================
    # LOAD REPOSITORY
    # =========================================================

    dialog.add_action_callback(
      'load_repository'
    ) do |_ctx|

      begin

        repository_data =
          load_repository_data

        @repository_runtime =
          repository_data[:attributes]

        @collections_runtime =
          repository_data[:collections]

        dialog.execute_script(
          "window.loadRepository(#{@repository_runtime.to_json})"
        )

        dialog.execute_script(
          "window.loadCollections(#{@collections_runtime.to_json})"
        )

      rescue => e

        puts e.message

      end

    end

    # =========================================================
    # SYNC REPOSITORY
    # =========================================================

    dialog.add_action_callback(
      'sync_repository'
    ) do |_ctx, json_data|

      begin

        @repository_runtime =
          JSON.parse(json_data)

        save_repository(
          @repository_runtime,
          @collections_runtime
        )

      rescue => e

        puts e.message

      end

    end

    # =========================================================
    # SAVE REPOSITORY
    # =========================================================

    dialog.add_action_callback(
      'save_repository'
    ) do |_ctx, json_data|

      begin

        @repository_runtime =
          JSON.parse(json_data)

        save_repository(
          @repository_runtime,
          @collections_runtime
        )

      rescue => e

        puts e.message

      end

    end

    # =========================================================
    # SYNC COLLECTIONS
    # =========================================================

    dialog.add_action_callback(
      'sync_collections'
    ) do |_ctx, json_data|

      begin

        @collections_runtime =
          JSON.parse(json_data)

        save_repository(
          @repository_runtime,
          @collections_runtime
        )

      rescue => e

        puts e.message

      end

    end

    # =========================================================
    # INSPECT COMPONENT
    # =========================================================

    dialog.add_action_callback(
      'inspect_component'
    ) do |_ctx|

      begin

        data =
          inspect_selected_component

        dialog.execute_script(
          "window.renderInspector(#{data.to_json})"
        )

      rescue => e

        puts e.message

      end

    end

    # =========================================================
    # APPLY COLLECTION
    # =========================================================

    dialog.add_action_callback(
      'apply_collection'
    ) do |_ctx, json_data|

      begin

        apply_attributes(json_data)

      rescue => e

        puts e.message

      end

    end

    # =========================================================
    # SELECT ATTRIBUTE
    # =========================================================

    dialog.add_action_callback(
      'select_attribute'
    ) do |_ctx, json_data|

      begin

        dialog.execute_script(
          "window.loadAttributeEditor(#{json_data})"
        )

      rescue => e

        puts e.message

      end

    end

    dialog.add_action_callback(
      'import_native_attribute'
    ) do |_ctx, native_name|

      begin

        result = add_native_to_repository(native_name)

        if result && result != false

          dialog.execute_script(
            "window.loadRepository(#{@repository_runtime.to_json})"
          )

        end

      rescue => e

        puts e.message

      end

    end

    dialog.add_action_callback(
      'load_native_catalog'
    ) do |_ctx|

      begin

        dialog.execute_script(
          "window.loadNativeCatalog(#{get_native_catalog_json})"
        )

      rescue => e

        puts e.message

      end

    end

    dialog

  end

  # =========================================================
  # LOAD REPOSITORY DATA
  # =========================================================

  def load_repository_data

    return {
      attributes: [],
      collections: []
    } unless File.exist?(REPOSITORY_PATH)

    xml_content =
      File.read(REPOSITORY_PATH)

    document =
      REXML::Document.new(xml_content)

    attributes = []
    collections = []

    document.elements.each(
      'InjectorRepository/AttributeLibrary/AttributeDefinition'
    ) do |node|

      attributes << {

        name:
          node.attributes['id'].to_s,

        value:
          node.elements['DefaultValue']&.text.to_s,

        formula:
          node.elements['Formula']&.text.to_s,

        units:
          node.elements['Units']&.text.to_s,

        access:
          node.elements['Access']&.text.to_s,

        label:
          node.elements['Label']&.text.to_s,

        formlabel:
          node.elements['FormLabel']&.text.to_s,

        formulaunits:
          node.elements['FormulaUnits']&.text.to_s,

        options:
          node.elements['Options']&.text.to_s,

        source:
          node.elements['Source']&.text.to_s

      }

    end

    document.elements.each(
      'InjectorRepository/Collections/Collection'
    ) do |node|

      collection = {

        name:
          node.attributes['name'].to_s,

        selected: []

      }

      node.elements.each(
        'Attribute'
      ) do |attr_node|

        collection[:selected] <<
          attr_node.attributes['name'].to_s

      end

      collections << collection

    end

    {
      attributes: attributes,
      collections: collections
    }

  end

  # =========================================================
  # LOAD FUNCTIONS DATA
  # =========================================================

  def load_functions_data

    return [] unless File.exist?(FUNCTIONS_PATH)

    xml_content =
      File.read(FUNCTIONS_PATH)

    document =
      REXML::Document.new(xml_content)

    functions = []

    document.elements.each('Functions/Function') do |node|

      functions << {

        name:
          node.elements['Name']&.text.to_s,

        category:
          node.elements['Category']&.text.to_s,

        syntax:
          node.elements['Syntax']&.text.to_s,

        description:
          node.elements['Description']&.text.to_s,

        example:
          node.elements['Example']&.text.to_s,

        source:
          node.elements['Source']&.text.to_s

      }

    end

    functions

  end

  # =========================================================
  # TEST FUNCTIONS CATALOG
  # =========================================================

  def test_functions_catalog

    functions = load_functions_data

    total_count = functions.length

    categories = functions.map { |f| f[:category] }.uniq.sort

    first_five = functions.take(5)

    result = {
      total_functions: total_count,
      categories: categories,
      first_five_functions: first_five.map { |f|
        {
          name: f[:name],
          category: f[:category],
          syntax: f[:syntax]
        }
      }
    }

    puts "=" * 60
    puts "FUNCTIONS CATALOG TEST"
    puts "=" * 60
    puts "Total Functions: #{result[:total_functions]}"
    puts "\nCategories Found:"
    result[:categories].each { |cat| puts "  - #{cat}" }
    puts "\nFirst 5 Functions:"
    result[:first_five_functions].each_with_index { |func, idx|
      puts "  #{idx + 1}. #{func[:name]} (#{func[:category]}) - #{func[:syntax]}"
    }
    puts "=" * 60

    result

  end

  # =========================================================
  # LOAD NATIVE CATALOG
  # =========================================================

  def load_native_catalog

    return [] unless File.exist?(NATIVE_CATALOG_PATH)

    xml_content =
      File.read(NATIVE_CATALOG_PATH)

    document =
      REXML::Document.new(xml_content)

    natives = []

    document.elements.each('NativeCatalog/Native') do |node|

      natives << {

        name:
          node.elements['Name']&.text.to_s,

        tag:
          node.elements['Tag']&.text.to_s,

        category:
          node.elements['Category']&.text.to_s,

        source:
          node.elements['Source']&.text.to_s,

        label:
          node.elements['Label']&.text.to_s,

        units:
          node.elements['Units']&.text.to_s,

        formulaunits:
          node.elements['FormulaUnits']&.text.to_s,

        access:
          node.elements['Access']&.text.to_s,

        formlabel:
          node.elements['FormLabel']&.text.to_s,

        options:
          node.elements['Options']&.text.to_s,

        default_value:
          node.elements['DefaultValue']&.text.to_s,

        formula:
          node.elements['Formula']&.text.to_s,

        protected:
          node.elements['Protected']&.text.to_s,

        renamable:
          node.elements['Renamable']&.text.to_s,

        deletable:
          node.elements['Deletable']&.text.to_s

      }

    end

    natives

  end

  # =========================================================
  # GET NATIVE CATALOG JSON
  # =========================================================

  def get_native_catalog_json

    load_native_catalog.to_json

  end

  # =========================================================
  # NATIVE -> ATTRIBUTE CONVERSION / IMPORT
  # =========================================================

  def native_to_attribute(native)

    return nil unless native

    {
      "name" => (native[:name] || native["name"]).to_s,
      "label" => (native[:label] || native["label"] || "").to_s,
      "units" => (native[:units] || native["units"] || "").to_s,
      "formulaunits" => (native[:formulaunits] || native["formulaunits"] || "").to_s,
      "access" => (native[:access] || native["access"] || "").to_s,
      "formlabel" => (native[:formlabel] || native["formlabel"] || "").to_s,
      "options" => (native[:options] || native["options"] || "").to_s,
      "value" => (native[:default_value] || native["default_value"] || "").to_s,
      "formula" => (native[:formula] || native["formula"] || "").to_s,
      "source" => (native[:source] || native["source"] || "dc_native").to_s
    }

  end

  def create_attribute_from_native(native_name)

    native = find_native_by_name(native_name)

    native_to_attribute(native)

  end

  def add_native_to_repository(native_name)

    native = find_native_by_name(native_name)

    return nil unless native

    attr = native_to_attribute(native)

    return nil unless attr

    return false if repository_contains_attribute?(attr["name"])

    @repository_runtime << attr

    attr

  end

  def find_native_by_name(name)

    catalog = load_native_catalog

    catalog.find do |n|
      (n[:name] || n["name"]) == name || (n[:tag] || n["tag"]) == name.to_s.downcase
    end

  end

  def repository_contains_attribute?(name)

    @repository_runtime.any? do |a|
      (a["name"] || a[:name]) == name
    end

  end

  def test_native_import

    result = add_native_to_repository("LenX")

    puts "test_native_import -> added: #{!result.nil? && result != false}"
    puts JSON.pretty_generate(@repository_runtime)

    result

  end

  def test_native_import_multiple

    %w[LenX LenY LenZ].each do |native_name|
      add_native_to_repository(native_name)
    end

    puts "test_native_import_multiple -> count: #{@repository_runtime.count}"
    puts JSON.pretty_generate(@repository_runtime)

    @repository_runtime

  end

  # =========================================================
  # SAVE XML REPOSITORY
  # =========================================================

  def save_repository(
    attributes,
    collections = []
  )

    attributes ||= []
    collections ||= []

    document =
      REXML::Document.new

    document << REXML::XMLDecl.new(
      '1.0',
      'UTF-8'
    )

    document.add_element(
      'InjectorRepository',
      {
        'version' => '1.0'
      }
    )

    repository =
      document.root

    library =
      repository.add_element(
        'AttributeLibrary'
      )

    attributes.each do |attr|

      next unless attr["name"]

      node =
        library.add_element(
          'AttributeDefinition',
          {
            'id' =>
              attr["name"].to_s
          }
        )

      node.add_element(
        'Label'
      ).text =
        attr["label"].to_s.empty? ?
          attr["name"].to_s :
          attr["label"].to_s

      node.add_element(
        'Units'
      ).text =
        attr["units"].to_s

      node.add_element(
        'Access'
      ).text =
        attr["access"].to_s

      node.add_element(
        'DefaultValue'
      ).text =
        attr["value"].to_s

      node.add_element(
        'Formula'
      ).text =
        attr["formula"].to_s

      node.add_element(
        'FormLabel'
      ).text =
        attr["formlabel"].to_s

      node.add_element(
        'FormulaUnits'
      ).text =
        attr["formulaunits"].to_s

      node.add_element(
        'Options'
      ).text =
        attr["options"].to_s

      node.add_element(
        'Source'
      ).text =
        attr["source"].to_s

    end

    collections_node =
      repository.add_element(
        'Collections'
      )

    collections.each do |collection|

      collection_node =
        collections_node.add_element(
          'Collection',
          {
            'name' =>
              collection["name"].to_s
          }
        )

      (collection["selected"] || []).each do |attr_name|

        collection_node.add_element(
          'Attribute',
          {
            'name' =>
              attr_name.to_s
          }
        )

      end

    end

    File.open(
      REPOSITORY_PATH,
      'w:utf-8'
    ) do |file|

      formatter =
        REXML::Formatters::Pretty.new(
          2
        )

      formatter.compact = true

      formatter.write(
        document,
        file
      )

    end

  end

  def internal_runtime_dc_attribute?(key)

    key_string = key.to_s

    hidden_keys = [
      '_formatversion',
      '_hasbehaviors',
      '_has_movetool_behaviors',
      '_lastmodified',
      '_inst_copy'
    ]

    return true if hidden_keys.include?(key_string)
    return true if key_string.end_with?('_error')

    false

  end

  # =========================================================
  # INSPECT COMPONENT
  # =========================================================

  
def inspect_selected_component

    model =
      Sketchup.active_model

    selection =
      model.selection

    return [] if selection.empty?

    entity =
      selection.first

    result = []

    dict = nil

    if entity.is_a?(Sketchup::ComponentInstance)

      dict =
        entity.definition.attribute_dictionary(
          "dynamic_attributes",
          false
        )

    elsif entity.is_a?(Sketchup::Group)

      dict =
        entity.attribute_dictionary(
          "dynamic_attributes",
          false
        )

    else

      return []

    end

    return [] unless dict

    dict.each_pair do |k,v|

      next if internal_runtime_dc_attribute?(k)

      result << {

        name:
          k,

        value:
          v,

        raw_value:
          v,

        label:
          dict["_#{k}_label"],

        formlabel:
          dict["_#{k}_formlabel"],

        units:
          dict["_#{k}_units"],

        formulaunits:
          dict["_#{k}_formulaunits"],

        access:
          dict["_#{k}_access"],

        formula:
          dict["_#{k}_formula"],

        options:
          dict["_#{k}_options"],

        source:
          entity.is_a?(Sketchup::Group) ?
            "group" :
            "definition",

        type:
          "attribute"

      }

    end

    result.sort_by do |a|

      a[:name].downcase

    end

  end


  # =========================================================
  # APPLY ATTRIBUTES
  # =========================================================

  def apply_attributes(json_data)

    attributes =
      JSON.parse(json_data)

    model =
      Sketchup.active_model

    selection =
      model.selection

    return if selection.empty?

    model.start_operation(
      "Aplicar Atributos",
      true
    )

    selection.each do |entity|

      next unless
        entity.is_a?(Sketchup::ComponentInstance) ||
        entity.is_a?(Sketchup::Group)

      target =
        entity.definition

      target.set_attribute(
        "dynamic_attributes",
        "_formatversion",
        "1.0"
      )

      target.set_attribute(
        "dynamic_attributes",
        "_hasbehaviors",
        "1.0"
      )

      attributes.each do |attr|

        name =
          attr["name"].to_s

        next if name.empty?

        value =
          attr["value"]

        formula =
           attr["formula"]

        units =
          attr["units"]

          if units == "AUTO_LENGTH"

            length_unit =
              Sketchup.active_model
                      .options["UnitsOptions"]["LengthUnit"]

            units =
              case length_unit
              when 2, 3, 4
                "CENTIMETERS"
              else
                "INCHES"
              end

          end

        access =
         attr["access"]

        label =
          attr["label"]

        formlabel =
          attr["formlabel"]

        formulaunits =
          attr["formulaunits"]

        options =
          attr["options"]

        

          target.set_attribute(
            "dynamic_attributes",
            name,
            value
          )

          target.set_attribute(
            "dynamic_attributes",
            "_#{name}_label",
            label.to_s.empty? ?
              name :
              label
          )

          unless access.to_s.strip.empty?

            target.set_attribute(
              "dynamic_attributes",
              "_#{name}_formlabel",
              formlabel.to_s.empty? ?
                name :
                formlabel
            )

            target.set_attribute(
              "dynamic_attributes",
              "_#{name}_access",
              access
            )

          end

          unless units.to_s.strip.empty?

            target.set_attribute(
              "dynamic_attributes",
              "_#{name}_units",
              units
            )

end

        unless formulaunits.to_s.empty?

          target.set_attribute(
            "dynamic_attributes",
            "_#{name}_formulaunits",
            formulaunits
          )

        end

        unless options.to_s.empty?

          target.set_attribute(
            "dynamic_attributes",
            "_#{name}_options",
            options
          )

        end

        unless formula.to_s.empty?

          target.set_attribute(
            "dynamic_attributes",
            "_#{name}_formula",
            formula
          )

        end

      end

      if defined?($dc_observers)

        begin

          $dc_observers
            .get_latest_class
            .redraw_with_undo(entity)

        rescue => e

          puts e.message

        end

      end

    end

    model.commit_operation

    begin

      inspector =
        inspect_selected_component

      @dialog.execute_script(
        "window.renderInspector(#{inspector.to_json})"
      )

    rescue => e

      puts e.message

    end

  end

  # =========================================================
  # MENU
  # =========================================================

  unless file_loaded?(__FILE__)

    UI.menu('Plugins').add_item(
      PLUGIN_NAME
    ) {

      show_ui

    }

    file_loaded(__FILE__)

  end

end