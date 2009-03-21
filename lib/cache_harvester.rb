# CacheHarvester

module CacheHarvester
  PREFIX = "harvestable"
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def cache_harvestable
      send :include, InstanceMethods
    end
    
    def index(suffix="max")
      "#{CacheHarvester::PREFIX}|#{self.name}|index|#{suffix}"
    end
    
    def index_min
      index("min")
    end
    
    def index_max
      index("max")
    end
    
    def next_index
      val = Rails.cache.increment(index_max)
      
      if val.nil?
        Rails.cache.write(index_min, 1, :raw => true)
        Rails.cache.write(index_max, 1, :raw => true)
        val = 1
      end
      
      val
    end
    
    def cache_key_for_index(index)
      "#{CacheHarvester::PREFIX}|#{self.name}|new|#{index}"
    end
    
    def load(ck)
      obj = Rails.cache.read(ck)
      if obj.nil?
        return nil
      else
        obj.key=ck
      end
      obj
    end
    
    def store(obj)
      Rails.cache.write(obj.key, obj)
      obj
    end
    
    ####################################################################
    # The following are to move data from the cache to the database
    ####################################################################
        
    # Saves the item from the cache to the database
    def save_from_cache(start=nil, stop=nil)
      if start.nil? || stop.nil?
        start = Rails.cache.read(index_min, :raw => true).to_i
        stop  = Rails.cache.read(index_max, :raw => true).to_i
      end
      
      t = start
      total = 0
      while t <= stop
        ck = cache_key_for_index(t)
        obj = load(ck)
        unless obj.nil?
          if obj.save!
            Rails.cache.delete(ck)
            total += 1
          end
        end
        
        t += 1
        Rails.cache.write(index_min, t, :raw => true)
      end
      
      total
    end
    
    def reset_indexes
      b = Rails.cache.read(index_min, :raw => true).to_i
      e = Rails.cache.read(index_max, :raw => true).to_i
      Rails.cache.delete(index_max)
      Rails.cache.delete(index_min)
      
      save_from_cache(b, e)
    end
    
  end

  module InstanceMethods
    def key
      if @cache_key.nil?
        @cache_key = self.class.cache_key_for_index(self.class.next_index)
      else
        @cache_key
      end
    end

    def key=(ck)
      @cache_key = ck
    end
    
    def store
      self.class.store(self)
    end
  end
end

ActiveRecord::Base.send :include, CacheHarvester
