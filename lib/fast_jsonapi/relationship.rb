module FastJsonapi
  class Relationship
    attr_reader :owner, :key, :name, :id_method_name, :record_type, :object_method_name, :object_block, :serializer, :relationship_type, :cached, :polymorphic, :conditional_proc, :transform_method, :links, :lazy_load_data

    def initialize(
      owner:,
      key:,
      name:,
      id_method_name:,
      record_type:,
      object_method_name:,
      object_block:,
      serializer:,
      relationship_type:,
      cached: false,
      polymorphic:,
      conditional_proc:,
      transform_method:,
      links:,
      lazy_load_data: false
    )
      @owner = owner
      @key = key
      @name = name
      @id_method_name = id_method_name
      @record_type = record_type
      @object_method_name = object_method_name
      @object_block = object_block
      @serializer = serializer
      @relationship_type = relationship_type
      @cached = cached
      @polymorphic = polymorphic
      @conditional_proc = conditional_proc
      @transform_method = transform_method
      @links = links || {}
      @lazy_load_data = lazy_load_data
      @record_types_for = {}
      @serializers_for_name = {}
    end

    def serialize(record, included, serialization_params, output_hash)
      if include_relationship?(record, serialization_params)
        initialize_static_serializer if !@initialized_static_serializer

        empty_case = relationship_type == :has_many ? [] : nil

        output_hash[key] = {}
        unless (lazy_load_data && !included)
          output_hash[key][:data] = ids_hash_from_record_and_relationship(record, serialization_params) || empty_case
        end
        add_links_hash(record, serialization_params, output_hash) if links.present?
      end
    end

    def fetch_associated_object(record, params)
      return object_block.call(record, params) unless object_block.nil?
      record.send(object_method_name)
    end

    def include_relationship?(record, serialization_params)
      if conditional_proc.present?
        conditional_proc.call(record, serialization_params)
      else
        true
      end
    end

    def serializer_for(record, serialization_params)
      if @static_serializer
        return @static_serializer

      elsif serializer.is_a?(Proc)
        serializer.arity.abs == 1 ? serializer.call(record) : serializer.call(record, serialization_params)

      elsif polymorphic
        name = polymorphic[record.class] if polymorphic.is_a?(Hash)
        name ||= record.class.name
        serializer_for_name(name)

      elsif object_block
        serializer_for_name(record.class.name)

      else
        raise "Unknown serializer for object #{record.inspect}"
      end
    end

    def static_serializer
      initialize_static_serializer
      @static_serializer
    end

    def static_record_type
      initialize_static_serializer
      @static_record_type
    end

    private

    def ids_hash_from_record_and_relationship(record, params = {})
      return ids_hash(fetch_id(record, params), @static_record_type) if @static_record_type

      return unless associated_object = fetch_associated_object(record, params)

      return associated_object.map do |object|
        id_hash_from_record object, params
      end if associated_object.respond_to? :map

      id_hash_from_record associated_object, params
    end

    def id_hash_from_record(record, params)
      associated_record_type = record_type_for(record, params)
      id_hash(record.public_send(id_method_name), associated_record_type)
    end

    def ids_hash(ids, record_type)
      return ids.map { |id| id_hash(id, record_type) } if ids.respond_to? :map
      id_hash(ids, record_type) # ids variable is just a single id here
    end

    def id_hash(id, record_type, default_return=false)
      if id.present?
        { id: id.to_s, type: record_type }
      else
        default_return ? { id: nil, type: record_type } : nil
      end
    end

    def fetch_id(record, params)
      if object_block.present?
        object = object_block.call(record, params)
        return object.map { |item| item.public_send(id_method_name) } if object.respond_to? :map
        return object.try(id_method_name)
      end
      record.public_send(id_method_name)
    end

    def add_links_hash(record, params, output_hash)
      if links.is_a?(Symbol)
        output_hash[key][:links] = record.public_send(links)
      else
        output_hash[key][:links] = links.each_with_object({}) do |(key, method), hash|
          Link.new(key: key, method: method).serialize(record, params, hash)\
        end
      end
    end

    def run_key_transform(input)
      if self.transform_method.present?
        input.to_s.send(*self.transform_method).to_sym
      else
        input.to_sym
      end
    end

    def initialize_static_serializer
      return if @initialized_static_serializer
      @initialized_static_serializer = true
      @static_serializer = fetch_static_serializer
      @static_record_type = fetch_static_record_type
    end

    def fetch_static_serializer
      if serializer.is_a?(Symbol) || serializer.is_a?(String)
        # a serializer was explicitly specified by name -- determine the serializer class
        serializer_for_name(serializer)

      elsif serializer.is_a?(Proc)
        # the serializer is a Proc to be executed per object -- not static
        nil

      elsif serializer
        # something else was specified, e.g. a specific serializer class -- return it
        serializer

      elsif polymorphic
        # polymorphic without a specific serializer --
        # the serializer is determined on a record-by-record basis
        nil

      elsif object_block
        # an object block is specified without a specific serializer --
        # assume the objects might be different and infer the serializer by their class
        nil

      else
        # no serializer information was provided -- infer it from the relationship name
        serializer_name = name.to_s
        serializer_name = serializer_name.singularize if relationship_type.to_sym == :has_many
        serializer_for_name(serializer_name)
      end
    end

    def serializer_for_name(name)
      @serializers_for_name[name] ||= compute_serializer_for_name(name)
    end

    def compute_serializer_for_name(name)
      namespace = owner.name.gsub(/()?\w+Serializer$/, '')
      serializer_name = name.to_s.demodulize.classify + 'Serializer'
      serializer_class_name = namespace + serializer_name
      begin
        return serializer_class_name.constantize
      rescue NameError
        raise "Cannot resolve a serializer class for '#{name}'.  " +
          "Attempted to find '#{serializer_class_name}'.  " +
          "You can specify the serializer directly, e.g. '#{relationship_type} #{self.name.to_sym.inspect}, serializer: #{serializer_class_name}'."
      end
    end

    def record_type_for(record, serialization_params)
      # if the record type is static, return it
      return @static_record_type if @static_record_type
      # if not, use the record type of the serializer, and memoize the transformed version
      serializer = serializer_for(record, serialization_params)
      @record_types_for[serializer] ||= run_key_transform(serializer.record_type)
    end

    def fetch_static_record_type
      return run_key_transform(record_type) if record_type
      return run_key_transform(@static_serializer.record_type) if @static_serializer
    end

  end
end
